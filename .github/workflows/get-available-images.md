<!-- start title -->

# GitHub Reusable Workflow: Get available images

<!-- end title -->
<!-- start description -->

Workflow to list available images regarding the "images" folder.

<!-- end description -->
<!-- start contents -->
<!-- end contents -->
<!-- start usage -->

```yaml
name: Get available images

on:
  pull_request:
    branches: [main]

jobs:
  get-available-images:
    uses: hoverkraft-tech/docker-base-images/.github/workflows/get-available-images.yml@0.1.0
```

<!-- end usage -->

<!-- start secrets -->
<!-- end secrets -->

<!-- start inputs -->
<!-- end inputs -->

<!-- start outputs -->

| **Output**          | **Description**                                  |
| ------------------- | ------------------------------------------------ |
| <code>images</code> | Available images. Example: ["php-8.2","node-18"] |

<!-- end outputs -->

<!-- start [.github/ghadocs/examples/] -->
<!-- end [.github/ghadocs/examples/] -->
