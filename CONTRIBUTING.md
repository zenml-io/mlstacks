Thank you for your interest in contributing a recipe to this repository! 🥳🙏
Here are some things that you should know before getting started.

## Get Started Quickly ⏩

## Principles and the structure of a recipe

### Modularity

The recipes are built in a modular fashion so that it's simple to build new ones
from parts of existing recipes.

- Inside a recipe, every file has the code responsible for creation of its
  namesake resources.

### Inputs

Each recipe takes user input in two forms:

- Values pertaining to non-sensitive configuration of individual stack
  components like name, region, allowed IPs, etc. are provided in the
  `locals.tf` file.
- Any sensitive information like MySQL passwords are passed as variables in the
  `variables.tf` file with their values in the `values.tfvars.json` file.

### Outputs

The outputs from each resource are used in two ways:

- In the form of terraform outputs in the `outputs.tf` file. These values are
  shown on the terminal after a successful execution of `terraform apply`.
- These values can also be used inside `output_file.tf` which is used to create
  the stack configuration file for ZenML to import your created resources.

## Testing your recipe

Each recipe can be tested using simple Terraform commands. You can go into the
relevant directory and execute `terraform init` and `terraform apply` to see how
the resources are being created. The code for integrating with ZenML resides on
the ZenML repository and you won't have to worry about testing it.

## Integrating with the ZenML stack

The integration with the ZenML stack CLI commands happens in two ways:

- The `output_file.tf` file creates a stack configuration YAML of all the
  relevant output values from the different resources that are created.
- You should add an output in the `outputs.tf` file with the name
  `stack-yaml-path` that outputs the name of the stack file. This is used by
  ZenML to import your stack automatically. Refer to existing recipes for the
  correct syntax.

## Workflow for adding a new recipe

When creating a new recipe, the first step would be to list out the components
that are a part of your stack. Going through each of the abstractions is a handy
way to ensure you have a complete stack.

Once the components are identified, take a look at the project `README` to check
if any existing recipes cover their creation.

### Adapting a component from another recipe

- The first step here is to identify the main component file. This is usually
  the file with the name of the component mentioned explicitly.

- Some components use resources that are spread across multiple files (secondary
  files). One way of identifying this is to look for any references made in the
  main file to the secondary files.

- One other dependency that you need to look for is the `depends_on` variable
  for any module. The presence of such a variable hints that the current module
  will need some parent module to run (as specified by the value of
  `depends_on`) before it.

- All of these files taken together compose your component and porting the
  component would mean copying each of these files into your new recipe.

### Adding new components

- When adding new components, try to use any existing modules as opposed to
  single resources. This ensures that the main resource and all of its
  dependencies are created together in a compact way and this also decreases the
  scope for errors while linking the parent and child resources.

- For every component that you add, make reasonable assumptions about the level
  of configurability that will be needed by the users of that resource. All
  customizable values should go into either the `locals.tf` file (non-sensitive)
  or the `values.tfvars` file (sensitive).

- For every component, create suitable outputs in the `output.tf` file and the
  `output_file.tf` file. These outputs should comprise only values that are
  essential for the user to communicate with the resource (for example, those
  that are required as inputs for the corresponding ZenML stack component)

## Pull Requests: Rebase Your Branch on Develop

1. When making pull requests to `mlstacks`, you should always make your changes
   on a branch that is based on `develop`. You can create a new branch based on
   `develop` by running the following command:
   ```
   git checkout -b <new-branch-name> develop
   ```
2. Fetch the latest changes from the remote `develop` branch:
   ```
   git fetch origin develop
   ```
3. Switch to your branch:
   ```
   git checkout <your-branch-name>
   ```
4. Rebase your branch on `develop`:
   ```
   git rebase origin/develop
   ```
   This will apply your branch's changes on top of the latest changes in
   `develop`, one commit at a time.
5. Resolve any conflicts that may arise during the rebase. Git will notify you
   if there are any conflicts that need to be resolved. Use a text editor to
   manually resolve the conflicts in the affected files.
6. After resolving the conflicts, stage the changes:
   ```
   git add .
   ```
7. Continue the rebase for all of your commits and go to 5) if there are
   conflicts.
   ```
   git rebase --continue
   ```
8. Push the rebased branch to your remote repository:
   ```
   git push origin --force <your-branch-name>
   ```
9. Open a pull request targeting the `develop` branch. The changes from your
   rebased branch will now be based on the latest `develop` branch.

## 🧐 Linting, formatting, and tests

To install `mlstacks` from your local checked out files including all core
dev-dependencies, run:

```bash
pip install -e ".[dev]"
```

Optionally, you might want to run the following commands to ensure you have all
integrations for `mypy` checks:

```bash
mypy --install-types
```

You can now run the following scripts to automatically format your code and to
check whether the code formatting, linting, docstrings, and spelling is in
order:

```
bash scripts/format.sh
bash scripts/lint.sh
```

Tests can be run as follows:

```
pytest tests
```

Please note that it is good practice to run the above commands before submitting
any Pull Request: The CI GitHub Action will run it anyway, so you might as well
catch the errors locally!

## Good Luck!

This should set you up to create new recipes quickly. If you're still unsure or
need help, feel free to connect with us on Slack or create an issue!
