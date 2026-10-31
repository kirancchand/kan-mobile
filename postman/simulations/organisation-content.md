# Organisation products and advertisements

From **My organisations**, members with `f_usertype_id` 5 or 6 can open the
menu next to Edit and select Products or Advertisements. Each screen lists
the organisation's content, supports pull-to-refresh/retry, and opens an add
form. Product selection uses the master product lookup. Advertisements require
an image and a valid start/end date range.

Request contracts come from `kanoct15.postman_collection.json`:

| Collection request | HTTP request |
| --- | --- |
| master/product/keyValue | POST `/keyValue`, `requestName: getAll_Product` |
| master/organisationProduct/add | POST `/master/organisationproduct/add` |
| master/organisationProduct/getById | GET `/master/organisationproduct/get/{organisationId}` |
| village/addadvertisement | POST `/api/advertisements`, multipart fields, selected `f_adv_type_id`, fixed `f_villageapp_id=1`, and image |
| village/getAll_AdvType | POST `/api/keyValue`, `requestName: getAll_AdvType` |
| village/getAdvertisementByOrganisation | GET `/api/advertisements/getAdvertisementByOrganisation/{organisationId}` |

Both APIs receive the signed-in bearer token, with one refresh/retry on 401.
Village requests also receive the configured `X-App-Id`. Multipart requests
use their generated Content-Type boundary. Ad types come from the configured
`getAll_AdvType` lookup before the user submits the selected type.

## Local verification

```sh
postman simulation run postman/simulations/organisation-content.sim.yaml --port 4916 --output ndjson
```

In another terminal:

```sh
/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin/flutter test test/organisation_content_test.dart test/organisation_content_widgets_test.dart --dart-define=organisation_content_simulation_url=http://127.0.0.1:4916/content
```

The simulation checks request methods, paths, product payloads, multipart image
and date fields, authentication refresh, read-after-write, and filtering out
other organisations/villages. It also exercises HTTP failures and malformed
responses. It uses synthetic records and no production writes. No shared
workspace mock was searched; this uses the supplied local collection.

Product saves validate failure flags/statuses in the response body, including
errors returned with HTTP 200, and show the server's rejection message. Before
displaying success, the client reads the organisation's products again and
requires the count of rows matching the submitted product, price, quantity and
description to increase. Existing identical rows cannot confirm a new insert.
If read-back fails or no new matching row appears, the form reports an
unconfirmed save and offers View products, without automatically resending the
POST. The simulation includes these rejection, no-op and read-back failure cases.

## Response assumptions requiring live confirmation

The collection contains no saved response examples. Lists accept bare arrays
or `data`/`result` wrappers. Products use `f_product_id`, `product_price`,
`product_qty`, `product_desc`, and optional `product`/`product_name` labels;
otherwise the dropdown supplies the label. Following the requested behaviour,
the ID in the collection's `getById` URL is treated as an organisation ID.
Confirm that this endpoint returns all products for that organisation rather
than a single organisation-product record.

Advertisements are fetched by organisation ID. The response is assumed to use
`advertisement_name`, `advertisement_desc`, `start_date`, and `end_date`; rows
with an explicit organisation ID are checked against the requested ID. Confirm
the live response fields and the shared ID format. The backend remains
responsible for enforcing membership permissions.
