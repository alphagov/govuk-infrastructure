# 22. Use Pkl for configuration

Date: 2025-11-06

## Status

Accepted

## Context

<!--
  Describe the problem being solved.
  Describe the context in which the decision is being made.
  Describe any relevant research that was conducted.
  Describe any other decisions that could have been made, and why we didn't make them.
-->

In ADRs [0018](./0018-use-concourse-ci.md), [0019](./0019-restructure-cicd.md),
and [0020](0020-use-crossplane-for-abstraction.md) we have made the decisions to use Concourse CI, restructure how we
do CI/CD, and to begin using Crossplane respectively.

Each of these tools and choices will require us to configure different things, such as Concourse and its pipelines, and
Crossplane's composite resources. The native configuration language for each of them is YAML.

As a team, we already maintain a lot of YAML code across things like
[our Helm charts](https://github.com/alphagov/govuk-helm-charts),
our [user access management](https://github.com/alphagov/govuk-user-reviewer),
and [our DNS](https://github.com/alphagov/govuk-dns-tf). We know from experience the pain involved with maintaining
large
amounts of YAML, especially when it is also being maintained by people outside the team, or when it is being fed as
input into another process which asserts a number of unwritten rules about its structure and properties (e.g. keys A and
B are exclusive, or when key C exists so should keys D or E).

Before we embarked on adding more YAML for us to maintain, we wanted to explore what options existed for generating YAML
from another language or tool that would provide us more support than we get from YAML. The positive attributes of
something in this role would include

* strong typing,
* an ability to model schemas and constraints,
* validation,
* good IDE support,
* and being able to output both YAML and JSON

### Research method

Our research method for finding the right thing for us had three stage: a long list, a short list, and a team
discussion.

At the long list stage, we went looking across the internet for tools and languages that were doing the kinds of job
that we were looking to fill. We drew up some rough criteria to compare them against (such as how they get installed,
what their standard libraries were like, and how well supported they were by common IDEs), and eventually selected three
to go on the short list.

At the short list stage we exercised the options in two ways

1. Writing code to replace our existing YAML for user access management; this is a data driven application with lots of
   repeated blocks with minimal changes (for example, just a name and email address changing)
2. Writing a Concourse pipeline in as concise and maintainable way as possible

At the final stage we presented the findings of the short list back to the team, and discussed the various trade-offs
and concerns.

### What did we evaluate

At the long list stage we evaluated

* [KCL](https://www.kcl-lang.io/)
* [Pkl](https://pkl-lang.org/)
* [Jsonnet](https://jsonnet.org/)
* [Dhall](https://dhall-lang.org/)
* [Cue](https://cuelang.org/)`
* Ruby
* Go
* JS/TS
* Python

From those, we short-listed

* KCL
* Pkl
* Go

#### Reasons for dropping at the long list stage

At the long list stage we dropped 2/3rds of the things we investigated. We explain below, in brief, why each one was
dropped.

##### Jsonnet and Dhall

Jsonnet and Dhall are both viable options in this space, but they did not perform as well in our assessment; Jsonnet’s
package libraries rely on third-party bundling of code into independent framework-like packages, and Dhall lacked
support for IntelliJ IDEs.

##### Cue

We chose not to continue with Cue because it lacks any official IDE support, and its package library ecosystem is slim
to non-existent.

##### Javascript and Python

Javascript and Python are both general purpose languages which would be up to the task, and have strong IDE support, but
we chose not to proceed with them because of their large installation footprint and constantly moving package ecosystem.
The type of code we’re writing may end up being written once, and modified a small number of times, but otherwise be 
static for years. Having a package ecosystem that requires constant bumps would be burdensome.

##### Ruby

Ruby has similar problems to Javascript and Python, but we opted not to proceed with it because there are no
pre-existing, relevant packages in its ecosystem. It would otherwise be a contender, because Ruby is a well-used
language in GOV.UK.

#### Reasons for not selecting at the short list

We ultimately chose not to use Go or KCL; the rationale for choosing Pkl is in the decision section.

##### Why not KCL

KCL and Pkl are similar in their design goals, purpose, and function. However, we found that KCL lacked some of the
features of Pkl, had some unfortunate shortcomings, and overall wasn't as mature or battle-tested as Pkl.

The first flaw we found, in comparison to Pkl, was a lack of validations and constraints on types. For example, in Pkl
we can write this:

```pkl
typealias Identifer = String(StartsWith("_"))
```

Which defines a type `Identifier` which is a string which much begin with an underscore. Every instance and use of that
type will be constrained to that rule, and that rule will be checked for every instance.

KCL has no such functionality. The closest replica is performing the validation of the constraint on every string that
you know to be an identifier. This is repetitive and error-prone.

The second flaw we found was in KCLs polymorphism. KCL allows you to define schemas (essentially classes), and for one
schema to extend another. However, unlike inheritance and polymorphism in most OOP languages, KCL does not allow for a
child type to change or further constrain the type of an attribute.

This flaw would be particularly bothersome when dealing with Concourse pipelines, where a number of things are
generically defined as a map of `string` to `any`. To make good use of a strongly typed configuration language, it would
be very useful to be able to extend the generic `Resource` type, for example, to create a more concrete `GitResource`
type with attributes for the keys required in the underlying map.

With respect to the maturity of the language, we found KCL lacked in two areas:

1. **Syntax highlighting**

   There is no syntax highlighting available in GitHub at the time of writing, which would make reading and reviewing
   the code harder than it ought to be. There is an open issue for adding support, but it appears to be a long way from
   happening.

2. **Editor support**

   A language server protocol implementation exists for KCL, but in VSCode and Vim we found it to be only just usable,
   and would crash when encountering cyclic dependencies. We did not try it in JetBrains' IDEs.

   By comparison, Pkl's editor support is strong and mature in all IDEs.

##### Why not Go

Go is a significantly different prospect than KCL or Pkl. Given that, we effectively compared the flexibility of Go with
the productivity of KCL and Pkl.

In favour of Go we found that much of the team was already familiar with the language, and many of the open source
projects we use (especially Concourse) are also written in Go and as a result we are able to make direct use of the
exact data structures those projects use for configuration.

We also found that the flexibility of Go as a general purpose language granted us the freedom to implement things to
exactly meet our needs.

The flip side of this flexibility is the need to do just that: implement everything. Where KCL and Pkl have
built-in, lightweight data modelling and serialisation, Go does not. One achieves that by creating new types and using
additional libraries. Atop this, Pkl, and to a lesser extent KCL, have good systems for constraining and validating
inputs as part of the language itself, whereas in Go it must be implemented in addition to the modeling and
serialisation.

Data modeling, serialisation, and validation of the types of configuration code we want to generate are not difficult
problems. The challenge lays in the volume of code needed, both in a single usage and across the entire estate, and the
potential for variability of quality in that code. Pkl and KCL, as domain specific languages, provide a uniform approach
to all of these problems, thereby reducing the variability between usages.

Go also imposes an additional, lifelong dependency maintenance burden for every single usage, both of the language
version and of all dependencies taken by the code. By comparison, KCL and Pkl have very minimal dependency footprints -
a single binary - and the same language version can be used globally across all usages.

## Decision

After the research and discussion outlined in the Context section, we have decided to use Pkl for configuration code
going forwards.

We have chosen Pkl because, of the options we short-listed, it was the most mature, well-supported, and feature rich
option; it has strong support in IDEs and on GitHub, like Go, but does not burden us with ongoing dependency
maintenance; it is strongly typed, and has native input constraints and validations; and it is a small enough language
for maintainers to master and write code of a consistent approach and quality.

We acknowledge that in choosing Pkl we are introducing another language into our toolkit, with everything that entails.
We feel that this is a worthwhile trade-off against the effort required to get a result of variable quality in Go. Pkl's
scope is small and well-defined, and it does not lend itself to being used in places to which it is not suited.

## Consequences

As a consequence of choosing a new language for configuration, we will be drawing a line, either side of which will be
considered the old and new way of doing things. At first this will mean that all of our configuration code is on the
old side of the line, but over time that percentage will get smaller.

We acknowledge that there may be some configuration we choose never to rewrite. We will not consider that to be
technical debt, for as long as it is actively maintained and in use in some capacity.

We think that Terraform configuration code is out of scope for being written in Pkl, because HCL is the accepted and
supported language.

Pkl code is intended to replace as much of our YAML code as we can, including the YAML maintained by our non-engineer
colleagues. The team will commit to learning Pkl itself, and provide documentation for using our Pkl codes bases, and 
training where necessary.