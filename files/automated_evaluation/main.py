### TO DO
### RETURN something

import functions_framework
from ranx import Qrels, Run, evaluate, compare
import pandas as pd
import numpy as np
import requests
import json
from typing import Union
from datetime import datetime
import pathlib
import matplotlib
from google.cloud import discoveryengine_v1beta
from google.protobuf.json_format import MessageToJson,MessageToDict
from itertools import islice
import gcsfs
from io import BytesIO
from datetime import datetime,timedelta
import ast

def interpolate_specs(i):
    FRESH_AGE = (datetime.now()-timedelta(weeks=1)).timestamp()
    RECENT_AGE = (datetime.now()-timedelta(weeks=12)).timestamp()
    OLD_AGE = (datetime.now()-timedelta(weeks=52)).timestamp()
    ANCIENT_AGE = (datetime.now()-timedelta(weeks=208)).timestamp()
    o=[]
    for k in i:
       o.append({"condition":k.get('condition').format(FRESH_AGE=FRESH_AGE,RECENT_AGE=RECENT_AGE,OLD_AGE=OLD_AGE,ANCIENT_AGE=ANCIENT_AGE),"boost":k.get('boost')})
    return o

def call_vertex_search(identifier:str,query:str,result_count: int,parameters:dict) -> dict:
  try:
    # Create a client
    client = discoveryengine_v1beta.SearchServiceClient()
    # Initialize request argument(s)
    request = discoveryengine_v1beta.SearchRequest(
      serving_config=identifier,
      query=query,
      page_size=result_count,
      boost_spec=discoveryengine_v1beta.SearchRequest.BoostSpec(parameters)
    )
    # Make the request
    results=[]
    page_result= client.search(request=request)
    for r_proto in islice(page_result,result_count):
      r = MessageToDict(r_proto._pb)
      results.append(r)
    if len(results)>0:
      # r_json={"results":json.loads(json.dumps(results))}
      r_json={"results":results}
      if len(r_json)>0:
        return r_json
      else:
        return {"results":[]}
    else:
      return {"results":[]}
  except Exception as e:
    print (e)
    return {"results":[]}

def collate_results(query: Union[int, str],identifier,attributes,domain,result_count,type,parameters) -> pd.DataFrame:

  if "vertex:search" in type:
    results= call_vertex_search(identifier=identifier,query=query,result_count=result_count,parameters=parameters).get("results", "")
  else:
    print(f'Unsupported type: {type}')
    results = {"results":[]}

  # normalize results into a dataframe
  data = pd.json_normalize(results)

  if len(data)>0:

    # default sim based on rank order if _index is mapped
    if "_index" in attributes:
      data = data.assign(sim=np.arange(1,0,(0-(1/len(data)))))

    # map attributes
    data=data.rename(columns=attributes)

    # select required attributes
    data=data[['docno','sim']]

    # strip domain from docno
    data['docno']=data['docno'].replace(domain, '', regex=False)

  else:

    data["docno"]=np.NaN
    data["sim"]=np.NaN

  # add query as a column to data, which will be used to merge data to df
  data['query'] = query

  # add rank number
  data["rank"] = data.groupby(['query']).cumcount()+1

  return data

def create_candidate_run (candidate,domain,result_count,query_count,requests_df):

  name=candidate['name']

  print(f'Retrieving {result_count} results for {query_count} queries on {name}')

  candidate['parameters']['condition_boost_specs']=interpolate_specs(candidate['parameters']['condition_boost_specs']) if candidate['parameters'].get('condition_boost_specs') is not None else None

  # call collate_results
  s = requests_df['query'].apply(collate_results,args=(candidate['identifier'],candidate['attributes'],domain,result_count,candidate['type'],candidate['parameters'],))

  # s is a Series of DataFrames, which can be combined with pd.concat
  s = pd.concat([v for v in s])

  # join df with s, on query
  results_df = requests_df.merge(s, on='query')

  # add constant columns
  c={'iter':'Q0','run_id':'STANDARD'}
  results_df=results_df.assign(**c)

  # select only required columns
  results_df=results_df[['query','iter','docno','rank','sim','run_id']]

  # load results df into run
  run = Run.from_df(
      df=results_df,
      q_id_col="query",
      doc_id_col="docno",
      score_col="sim"
  )
  run.name=candidate['name']

  return(run)

def create_subfolders(folder,subfolders):
  if not "gcs://" in folder:
    for subfolder in subfolders:
        pathlib.Path(folder + '/' + subfolder).mkdir(parents=True, exist_ok=True)

def split_autocomplete_query(query:str) -> list:
  lst=[]
  for i,chr in enumerate(query):
    lst.append(query[:i+1:1])
  return lst

def save_json(x: dict, path: str, project: str) -> None:
    if "gcs://" in path:
      fs=gcsfs.GCSFileSystem(project=project)
      with fs.open(path, "w") as f:
        f.write(json.dumps(x))
    else:
      with open(path, "w") as f:
        f.write(json.dumps(x))

def load_json(path: str, project:str) -> str:
    if "gcs://" in path:
      fs=gcsfs.GCSFileSystem(project=project)
      with fs.open(path, "r") as f:
        return json.loads(f.read())
    else:
      with open(path, "r") as f:
        return json.loads(f.read())

def save_fig(x, path: str, format: str, project:str) -> None:
    figfile = BytesIO()
    x.savefig(figfile, format=format)
    if "gcs://" in path:
      fs=gcsfs.GCSFileSystem(project=project)
      with fs.open(path, "wb") as f:
        f.write(figfile.getvalue())
    else:
      with open(path, "wb") as f:
        f.write(figfile.getvalue())

@functions_framework.http
def automated_evaluation(request):
    config = request.get_json(silent=True)
    import os
    project = os.environ.get("PROJECT_NAME")

    domain=config['domain']
    query_count=config['query_count']
    result_count=config['result_count']
    execution_name = f'ts=' + datetime.now().strftime('%Y-%m-%dT%H:%M:%S') + f'/qc={query_count}/rc={result_count}'
    output_folder=config['output_folder'] + '/' + execution_name

    for judgement in config['judgements']:

        judgement_name=judgement['name']
        attributes= judgement.get('attributes',{})

        create_subfolders(folder=output_folder,subfolders=[f'judgement_list={judgement_name}'])

        print(f'Preparing {query_count} {judgement_name} judgements')

        # read judgements data from file
        judgements_df=pd.read_csv(judgement['url'], sep=',')

        # refine to approved columns
        judgements_df=judgements_df.rename(columns=attributes)

        # select required attributes
        judgements_df=judgements_df[['query','link','score']].dropna()

        # force score to numeric
        judgements_df=judgements_df.astype({"query":str,"link":str,"score": int})

        # get unique list of queries from judgement list
        requests_df=judgements_df.drop_duplicates(subset=['query'])

        # use the first x queries
        requests_df=requests_df.head(query_count)

        # if judgement type is explode then break down queries i.e. for autosuggest
        if judgement.get('type'):
            if judgement['type']=="explode":
                requests_df['query']=requests_df['query'].apply(split_autocomplete_query)
                requests_df=requests_df.explode('query')
                judgements_df=requests_df

        # filter qrels to first x query groups
        qrels_df=judgements_df[judgements_df['query'].isin(requests_df['query'])]

        # load qrels df into qrels
        qrels = Qrels.from_df(
            df=qrels_df,
            q_id_col="query",
            doc_id_col="link",
            score_col="score",
        )
        qrels_json_path=f'{output_folder}/judgement_list={judgement_name}/qrels.json'
        save_json(qrels.to_dict(),qrels_json_path,project)

        # save qrels in CSV format
        df = pd.read_json(qrels_json_path)
        df = df.melt(ignore_index=False,var_name='query',value_name='judgement').dropna()
        df.to_csv(f'{output_folder}/judgement_list={judgement_name}/qrels.csv')

        runs=list()

        for candidate in config['candidates']:

            run=create_candidate_run(
                candidate=candidate,
                domain=domain,
                result_count=result_count,
                query_count=query_count,
                requests_df=requests_df
            )

            evaluate(
                qrels=qrels,
                run=run,
                metrics=config['metrics'],
                return_mean=False,
                save_results_in_run=True,
                make_comparable=True
            )

            name=run.name

            create_subfolders(folder=output_folder,subfolders=[f'judgement_list={judgement_name}/candidate={name}'])

            run_json_path=f'{output_folder}/judgement_list={judgement_name}/candidate={name}/run.json'

            # save run in json format
            save_json(run.to_dict(),run_json_path,project)

            # save run in CSV format
            df = pd.read_json(run_json_path)
            df = df.melt(ignore_index=False,var_name='query',value_name='score').dropna()
            df.to_csv(f'{output_folder}/judgement_list={judgement_name}/candidate={name}/run.csv')


            # save evaluate results in json format
            result_json_path=f'{output_folder}/judgement_list={judgement_name}/candidate={name}/results.json'
            save_json(run.scores,result_json_path,project)

            # save evaluate results in csv format
            df=pd.read_json(result_json_path)
            df.to_csv(f'{output_folder}/judgement_list={judgement_name}/candidate={name}/results.csv')

            # save evaluate results in png format
            fig = df.plot(title=judgement_name + '_' + name, kind='bar', figsize=(20, 16), fontsize=16, rot=45, ylim=(0,1)).get_figure()
            save_fig(fig,f'{output_folder}/judgement_list={judgement_name}/candidate={name}/results.png','png', project)
            matplotlib.pyplot.close(fig)

            # append run to runs list
            runs.append(run)

        print('Comparing results and generating report')

        # run compare on runs and load into report
        report = compare(
            qrels=qrels,
            runs=runs,
            metrics=config['metrics'],
            show_percentages=config['show_percentages'],
            max_p=config['max_p']  # P-value threshold
        )

        report_json_path=f'{output_folder}/judgement_list={judgement_name}/report.json'
        save_json(report.to_dict(),report_json_path,project)

        # save report in csv format
        report_json=load_json(report_json_path,project)

        df = pd.DataFrame()
        for i in report_json['model_names']:
            x = pd.json_normalize(data=report_json[i]['scores'])
            x['model']=i
            df = pd.concat([df,x])

        df.to_csv(f'{output_folder}/judgement_list={judgement_name}/report.csv')

        fig = df.plot(title=judgement_name, kind='bar', figsize=(20, 16), fontsize=16, rot=45, x='model', ylim=(0,1)).get_figure()
        save_fig(fig,f'{output_folder}/judgement_list={judgement_name}/report.png','png',project)
        matplotlib.pyplot.close(fig)

        # print report
        print(report)

    return 'something'
