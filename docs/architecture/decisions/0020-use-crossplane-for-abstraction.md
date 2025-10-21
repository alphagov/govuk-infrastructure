# 20. Use Crossplane for abstraction

Date: 2025-10-20

## Status

Accepted

## Context

Applications deployed on Kubernetes need a number of different resources to function: pods, replica sets, deployments,
services, ingresses etc. Knowing what resources are needed, how they are configured, and how they are interrelated
requires a good amount of Kubernetes knowledge, as well as knowledge of how the rest of your infrastructure is set up.
This knowledge is readily available within the Platform Engineering team, but less so among the application teams we
serve.

To address this, and to try to standardise and simplify the way teams were deploying applications, we built a generic
Helm chart. The chart was intended to support every team, no matter what they needed. As a result, over time it grew to
include a lot of components: database migrations, Redis, cron jobs, autoscaling, service accounts and more. For us, as a
Platform Engineering team, this had led to a code base that:

* has lots of Golang templates embedded in YAML,
* has lots of importins and variable values derived from other variables,
* is hard to navigate,
* is hard to reason about,
* is hard to change,
* and is easy to get wrong.

Given these failings, we have wanted to improve the way that teams describe the Kubernetes resources needed for their
applications in one way or another.

A number of team members had been aware of [Crossplane](https://www.crossplane.io/), a "Cloud-Native Framework for
Platform Engineering", for some time. In a firebreak in September 2025, we decided to experiment with it. We had good
experiences with it, and at a post-firebreak show and tell the team was enthusiastic about the possibilities presented
by Crossplane's capabilities.

In our team design day on October 15th 2025 we made the decision to use Crossplane.

### Crossplane features

The Kubernetes [API can be extended](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/) using custom
resources. Crossplane has extended the API with a `CompositeResource` resource type, a resource type that "represents a
set of Kubernetes resources as a single Kubernetes object", and a `CompositeResourceDefinition` resource type that
describes the schema of a custom API.

A third feature of Crossplane is compositions. Compositions are like templates for turning an object described by a
`CompositeResourceDefinition` into a `CompositeResource` and the other Kubernetes resources it represents.

Another feature of Crossplane we plan to use is its ability to create cloud resources when a custom API type is
submitted. For example, a `PostgresDatabase` type can be defined using a `CompositeResourceDefintiion`, and when one is
submitted, a database can created in AWS RDS.

## Decision

We have decided that we want to employ Crossplane to create a Kubernetes-flavoured API for our users that abstracts the
types of resources our users need to create at a higher level than offered by the standard Kubernetes API.

The finer details of what Crossplane is and how it works are out of scope for this ADR. Light touch explanations are
provided here to contextualise the decisions we have made.

### Creating an API

We plan to create an API with types that represent the high-level concepts our users want to deploy: apps, backing
services, routes etc. The actual types we will need to create are not yet decided on, the aforementioned types are
simply illustrative.

### Backing services

We plan to use this feature to create a catalogue of backing services our users can get access to via Kubernetes. This
will eventually replace creating application backing services in Terraform. The backing services we will offer is not
yet decided.

### Changing where the code lives

Another decision we made as part our decision to use Crossplane is to change where teams' application infrastructure
source code lives. Today, each application has a set of YAML files providing values for the generic Helm chart in a
single Git repository.

Teams make changes to their application infrastructure by modifying the YAML files in the repository, and working with
us to modify the Helm chart if they need something new or that cannot be changed with a variable.

When a deployment is being performed, the relevant YAML files are updated by an automated process with the new container
image tags.

We plan to move from a model where every application's infrastructure code lives in the same repository, to one where
each application repository contains its own infrastructure code. We do not yet know what that code will look like; we
expect the decision will be made in an upcoming ADR about our choice of YAML generation tool.

The way in which this affects the deployment process is documented in [ADR019](./0019-restructure-cicd.md).

### Stages of implementation

Our implementation of Crossplane and a new API abstraction will likely have three phases. We will describe here what we
expect the three phases to look like, but offer no timelines.

#### 1. Ideation and alpha implementation

We will begin by working out what concepts we want to include in the abstraction, and how we should implement them. This
will form an alpha version of the API. We will build out enough of it to be able to approach a team about migrating
their application infrastructure to using it. We know that we will learn much more about what the API should look like
and how it should be implemented by making use of it in production.

#### 2. Migration of all applications

After we have worked with one team to begin using the new API, we will systematically work through every application
from every team to migrate them to the new API. This will take a long time.

#### 3. Migration of backing services

In the previous two stages, we will have focussed exclusively on the way in which teams' applications are deployed. In
the third and final stage, we will create a service catalog in the Kubernetes API and migrate all existing backings
services to be represented, and managed by, tha API.

## Consequences

### Time and energy

To implement the decisions we have made we expect will require a large investment of time and energy, over the course of
at least a year. During that time we expect to have different applications using different methods of describing their
infrastructure, and there to be some amount of confusion over which application is using which method. We accept this
as a cost of doing the rework.

Because of the long timeline, there is also a risk of the work needing to be shelved part way through in favour of a
more urgent piece of work.

### Technical debt

Whilst we rework ou CI/CD infrastructure, we know that we will have to make compromises and have messy code in different
parts of the system. This will inevitably accrue as technical debt. We will do our best to prevent this and pay down
debt as we go, but there is very likely to be some left over when we are finished.

### Increased need for quality documentation

We will need to produce more good quality documentation for the API we are producing. To date we have been able to rely
on the Kubernetes documentation, but for our own API we will be the sole authority.

### Increased test coverage required

The new API, compositions, cloud resources etc will require us to have a better test suite for the platform itself. We
will have to expand our end-to-end test, smoke test, and integration test suites. 
