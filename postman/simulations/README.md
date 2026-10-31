# Organisation membership smoke test

The request paths and methods come from `kanoct15.postman_collection.json`.
The membership response uses the `{message, status, data: [...]}` envelope
confirmed by the supplied API response. The app also accepts a bare list and
a `result` list wrapper. The mock uses synthetic records. No shared workspace mock was searched: this test uses
the supplied local collection and does not require a Postman account.

Start the local simulation:

```sh
postman simulation run postman/simulations/organisations.sim.yaml --port 4908 --output ndjson
```

In another terminal, run:

```sh
/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin/flutter test test/my_organisations_test.dart --dart-define=organisation_simulation_url=http://127.0.0.1:4908/kan
```

The test logs in using `userInfo.data.user_id`, lists memberships for user 624, rejects editing an entry with
`f_usertype_id=7`, updates the entry with `f_usertype_id=5`, and reads back the new name.
The separate permission test covers numeric/string 5 and 6 and denied values.
The backend must independently enforce update authorization.
