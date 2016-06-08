plv8 = require('../../../plpl/src/plv8')
assert = require('assert')

describe 'Issues', ->
  before ->
    plv8.execute("SET plv8.start_proc = 'plv8_init'")

  it '#124', ->
    plv8.execute('''
      SELECT fhir_create_storage('{"resourceType": "Patient"}');
    ''')
    plv8.execute('''
      SELECT fhir_truncate_storage('{"resourceType": "Patient"}');
    ''')

    transaction =
      JSON.parse(
        plv8.execute('''
          SELECT fhir_transaction('
            {
              "resourceType":"Bundle",
              "type":"transaction",
              "entry":[
                {
                  "resource":{
                    "resourceType":"UnknownResource",
                    "active":true,
                    "name":[
                      {"use":"official","family":["Snow"],"given":["John"]}
                    ],
                    "gender":"male",
                    "birthDate":"2001-01-01"
                  },
                  "request":{
                    "method":"POST","url":"UnknownResource"
                  }
                }
              ]
            }
          ');
        ''')[0].fhir_transaction
      )

    assert.equal(transaction.resourceType, 'OperationOutcome')
    assert.equal(
      transaction.issue[0].diagnostics,
      'Storage for UnknownResource not exists'
    )
