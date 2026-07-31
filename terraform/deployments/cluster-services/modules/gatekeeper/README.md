# govuk-terraform-gatekeeper

> This module is built by pulling in the relevant policies and code from it's [parent repo](https://github.com/alphagov/govuk-terraform-gatekeeper). Notably, we have removed the mutations, we may want to add these in later to increase our pods security posture.

Kubernetes allows decoupling policy decisions from the API server by means of admission controller webhooks to intercept admission requests before they are persisted as objects in Kubernetes. Gatekeeper is a customizable admission webhook for Kubernetes that enforces policies executed by the Open Policy Agent (OPA), a policy engine for Cloud Native environments hosted by CNCF.

## Usage

The order which resources are created are important, to control resource creation order `constraint_templates` and `constraints` are broken into sub-modules.
A downside of this approach, is that you have to pass variables twice (small amount of "dry"), once into the parent module and then again to the constraints module. However, the benefits are that we can easily create constraints and templates with terraform loops and control resource creation order.

### Adding a new constraint:

1. Create a constraint template under the `resources/constraint_templates` folder
2. Create a constraint file under the `resources/constraints` folder
3. Update the `constraint_map` in the local block in the `constraints/locals.tf` file
4. Update the `dryrun_map` variable in the `variables.tf` and `constraints/variables.tf` files

### Configuring constraints

The constraint template design allows you to define a template and then instantiate different constraints from that template.
Constraints are flexible and can take input variables, the best way to configure these parameters from terraform values is through `constraints/locals.tf`.
In `constraints/locals.tf` we read the constraint from yaml and convert it to json so you can change values and add new keys easily. We convert this back into yaml for terraform to apply as a k8s manifest.

### Caveats: 

 - to generate the audit report, it seems advisable to query a cache of filtered K8s objects, rather than hit the API each time (60 sec intervals default); because of that any kind used by a constraint template must also be added to the sync config at the end of constraints.tf
 - deleting a ConstraintTemplate that still has Constraints breaks things badly; only deleting the CRDs (which in turn removes all the constraints) unblocks again
 - no colons (:) in the description field

## Testing

gatekeeper provides a neat [cli tool](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/) for testing. Once installed you can run the following command to verify the test suite has the expected violations:

```sh
gator verify test/suite/...
```

When adding new tests, test data goes under their own dir `test/suite/samples/test_suite_name/`, `case.yaml` contains config for the resource being tested, `inventory.yaml` contains config for 'mock resources', and the test suite file can be found in `test/suite/test_suite_name.yaml`, see diagram below:

```
test/suite
├── samples/
│   └── test_suite_name/
│       ├── case_description_1/
│       │   ├── case.yaml
│       │   └── inventory.yaml
│       └── case_description_2
│           ├── case.yaml
│           └── inventory.yaml
└── test_suite_name.yaml
```

## Reading Material

[What is OPA Gatekeeper?](https://www.openpolicyagent.org/docs/latest/kubernetes-introduction/#what-is-opa-gatekeeper)
[OPA Gatekeeper Library](https://github.com/open-policy-agent/gatekeeper-library)
