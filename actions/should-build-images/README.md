<!-- header:start -->

# ![Icon](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJmZWF0aGVyIGZlYXRoZXItY2hlY2stc3F1YXJlIiBjb2xvcj0iYmx1ZSI+PHBvbHlsaW5lIHBvaW50cz0iOSAxMSAxMiAxNCAyMiA0Ij48L3BvbHlsaW5lPjxwYXRoIGQ9Ik0yMSAxMnY3YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0yVjVhMiAyIDAgMCAxIDItMmgxMSI+PC9wYXRoPjwvc3ZnPg==) GitHub Action: Should build the given images

<div align="center">
  <img src="https://opengraph.githubassets.com/34115c9c7eef85e3fbc359b8210083e8379c2ba3cf6240ba80f413d72803f687/hoverkraft-tech/docker-base-images" width="60px" align="center" alt="Should build the given images" />
</div>

---

<!-- header:end -->
<!-- badges:start -->

[![Marketplace](https://img.shields.io/badge/Marketplace-should--build--the--given--images-blue?logo=github-actions)](https://github.com/marketplace/actions/should-build-the-given-images)
[![Release](https://img.shields.io/github/v/release/hoverkraft-tech/docker-base-images)](https://github.com/hoverkraft-tech/docker-base-images/releases)
[![License](https://img.shields.io/github/license/hoverkraft-tech/docker-base-images)](http://choosealicense.com/licenses/mit/)
[![Stars](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)](https://img.shields.io/github/stars/hoverkraft-tech/docker-base-images?style=social)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md)

<!-- badges:end -->
<!-- overview:start -->

## Overview

Check if some files have changed requiring the build of the given images.

<!-- overview:end -->
<!-- usage:start -->

## Usage

```yaml
- uses: hoverkraft-tech/docker-base-images/actions/should-build-images@ad965683cf180fd7b09b6bd3948fdc1a164c6661 # 0.2.0
  with:
    # Image names located in the 'images' folder.
    # Formatted as a JSON array.
    # Example: `["php-8", "nodejs-24"]`
    #
    # This input is required.
    images: ""

    # Specify a different base commit SHA used for comparing changes. See https://github.com/tj-actions/changed-files
    base-sha: ""
```

<!-- usage:end -->
<!-- inputs:start -->

## Inputs

| **Input**      | **Description**                                                                                                   | **Required** | **Default** |
| -------------- | ----------------------------------------------------------------------------------------------------------------- | ------------ | ----------- |
| **`images`**   | Image names located in the 'images' folder.                                                                       | **true**     | -           |
|                | Formatted as a JSON array.                                                                                        |              |             |
|                | Example: `["php-8", "nodejs-24"]`                                                                                 |              |             |
| **`base-sha`** | Specify a different base commit SHA used for comparing changes. See <https://github.com/tj-actions/changed-files> | **false**    | -           |

<!-- inputs:end -->
<!-- secrets:start -->
<!-- secrets:end -->
<!-- outputs:start -->

## Outputs

| **Output**                | **Description**                                                                                                             |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **`should-build-images`** | Whether or not the images should be built.                                                                                  |
|                           |                                                                                                                             |
|                           | Formatted as a JSON object.                                                                                                 |
|                           |                                                                                                                             |
|                           | Example:                                                                                                                    |
|                           |                                                                                                                             |
|                           | <!-- textlint-disable --><pre lang="json">{&#13; "php-8": true,&#13; "nodejs-24": false&#13;}</pre><!-- textlint-enable --> |
| **`changed-files`**       | The files related to given images building that have changed, if any                                                        |

<!-- outputs:end -->
<!-- examples:start -->
<!-- examples:end -->

<!--
// jscpd:ignore-start
-->

<!-- contributing:start -->

## Contributing

Contributions are welcome! Please see the [contributing guidelines](https://github.com/hoverkraft-tech/docker-base-images/blob/main/CONTRIBUTING.md) for more details.

<!-- contributing:end -->
<!-- security:start -->
<!-- security:end -->
<!-- license:start -->

## License

This project is licensed under the MIT License.

SPDX-License-Identifier: MIT

Copyright © 2026 hoverkraft

For more details, see the [license](http://choosealicense.com/licenses/mit/).

<!-- license:end -->
<!-- generated:start -->

---

This documentation was automatically generated by [CI Dokumentor](https://github.com/hoverkraft-tech/ci-dokumentor).

<!-- generated:end -->

<!--
// jscpd:ignore-end
-->
