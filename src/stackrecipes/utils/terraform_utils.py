import python_terraform


class TerraformRunner:
    def __init__(self, tf_recipe_path):
        self.tf_recipe_path = tf_recipe_path

        self.client = python_terraform.Terraform(
            working_dir=self.tf_recipe_path,
        )
