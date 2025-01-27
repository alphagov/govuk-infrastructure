import { Firehose } from '@aws-sdk/client-firehose'

// This collection can contain strings or regexs and prevents matches from
// being logged in firehose. This is list is mostly comprised of browser
// extension embeds and JS automatically inserted into web pages by apps
// (e.g. Instagram). It will never be exhaustive, but can filter out a lot
// of the noise.
const BLOCKED_URIS_TO_FILTER = [
  'eval',
  'wasm-eval',
  'data',
  'blob',
  'asset',
  'self',
  'null',
  // these may be standalone or scheme prefixes
  /^file/,
  /^safari-web-extension/,
  /^chrome-extension/,
  /^moz-extension/,
  // schemes
  /^gsa:/,
  /^ws:/, // GOV.UK doesn't currently use any websockets
  // 3rd party embedded reosources, many are fonts
  /^https:\/\/connect\.facebook\.net/,
  /^https:\/\/[^.]*\.gstatic\.com/, // we tend to get www.gstatic.com and fonts.gstatic.com
  /^https:\/\/fonts\.googleapis\.com/,
  /^https:\/\/translate\.google(apis)?\.com/, // we get both google.com and googleapis.com
  /^https:\/\/at\.alicdn\.com/,
  /^https:\/\/www\.google\.com/,
  /^https:\/\/pouch-global-font-assets\.s3/,
  /^https:\/\/mozbar\.moz\.com/,
  /^https:\/\/metrics2\.data\.hicloud\.com/,
  /^https:\/\/use\.typekit\.net/,
  /^https:\/\/cdn\.jsdelivr\.net/,
  /^https:\/\/www\.slant\.co/,
  /^https:\/\/fonts\.bunny\.net/,
  /^https:\/\/github\.com/,
  /^https:\/\/yastatic\.net/,
  /^https:\/\/static3\.avast\.com/,
  /^https:\/\/pwm-image\.trendmicro\.com/,
  /^https:\/\/api\.ultimateaderaser\.com/,
  /^https:\/\/api\.crystal-blocker\.com/,
  /^https:\/\/solarspireconsulting\.com/,
  /^https:\/\/solaranalyticscorp\.com/,
  /^https:\/\/socialsolutionapp\.com/,
  /^https:\/\/global-data-lab\.com/
]

function buildReport (json, sourceIp, userAgent) {
  const cspReport = json['csp-report'] || {}
  const now = new Date()

  // using snake casing for easier usage in AWS Glue
  return {
    time: now.toISOString(),
    document_uri: normaliseInputString(cspReport['document-uri']),
    referrer: normaliseInputString(cspReport.referrer),
    blocked_uri: normaliseInputString(cspReport['blocked-uri']),
    effective_directive: normaliseInputString(cspReport['effective-directive']),
    violated_directive: normaliseInputString(cspReport['violated-directive']),
    disposition: normaliseInputString(cspReport.disposition),
    sample: normaliseInputString(cspReport['script-sample']),
    line_number: normaliseInteger(cspReport['line-number']),
    status_code: normaliseInteger(cspReport['status-code']),
    original_policy: normaliseInputString(cspReport['original-policy']),
    source_ip: normaliseInputString(sourceIp),
    user_agent: normaliseInputString(userAgent)
  }
}

function normaliseInputString (input) {
  if (!input) return null

  const string = String(input)

  if (string.length > 4000) {
    // lets not store anything suspiciously long
    return string.slice(0, 4000)
  } else {
    return string
  }
}

function normaliseInteger (input) {
  return Number.isInteger(input) ? input : null
}

// we seem to get base64 submitted, not sure if this is something API gateway
// can resolve
function parseBody (body) {
  // Try decode base64
  try {
    const buffer = Buffer.from(body, 'base64')
    return JSON.parse(buffer.toString())
  } catch {
    // otherwise try regular body
    return JSON.parse(body)
  }
}

async function sendReportToFirehose (report) {
  const client = new Firehose()
  await client.putRecord({
    DeliveryStreamName: process.env.FIREHOSE_DELIVERY_STREAM,
    Record: {
      Data: Buffer.from(JSON.stringify(report))
    }
  })
}

function filterBlockedUri (uri) {
  return BLOCKED_URIS_TO_FILTER.some((filter) => {
    return (filter instanceof RegExp) ? uri.match(filter) : uri === filter
  })
}

export const handler = async (event) => {
  // Not sure whether the case of this is dependent on the client or API Gateway
  const contentType = event.headers['Content-Type'] || event.headers['content-type']

  if (!['application/csp-report', 'application/json'].includes(contentType)) {
    console.log(`Client error: content type '${contentType}' wasn't application/csp-report or appliation/json`)
    return { statusCode: 415 }
  }

  let json

  try {
    json = parseBody(event.body)
  } catch {
    console.log('Client error: failed to parse body')
    return { statusCode: 400 }
  }

  // These identity variables are present if API Gateway proxies to this
  const report = buildReport(json, event.requestContext?.http?.sourceIp, event.requestContext?.http?.userAgent)

  // if we have no data lets not bother sending
  if (!report.blocked_uri) {
    console.log('Client error: no blocked-uri, not logging report')
    return { statusCode: 400 }
  } else if (filterBlockedUri(report.blocked_uri)) {
    console.log(`Report dropped: blocked-uri, ${report.blocked_uri} is filtered from our logging`)
    return { statusCode: 200 }
  } else {
    await sendReportToFirehose(report)
    console.log('Report logged with firehose')
    return { statusCode: 201 }
  }
}
