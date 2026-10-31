Feature: Crear Mascotas

  Scenario: Crear nuevo perro

  Given url 'http://localhost:3000/pets'
    And request
      """
      {
        "name": "Brownie",
        "type": "Perro",
        "age": 5
      }
      """
      When method post
        Then status 201
        And def petId = $.data.id
        And print petId

  Scenario: Buscar perro

    Given url 'http://localhost:3000/pets/' + '1793394874103'
    When method get
    Then status 200
    And print "yeeeeahh"

  Scenario: Crear y Buscar perro
    Given url 'http://localhost:3000/pets'
    And request
      """
      {
        "name": "Brownie",
        "type": "Perro",
        "age": 5
      }
      """
    And method post
    And status 201
    And def petId = $.data.id

    Given url 'http://localhost:3000/pets/' + petId
    When method get
    Then status 200
    And print "se encontró el perro con el id: " + petId

  Scenario: Actualizar mascota

    Given url 'http://localhost:3000/pets'
    And request
      """
      {
        "name": "Kitty",
        "type": "Perro",
        "age": 8
      }
      """
    And method post
    And status 201
    And def petId = $.data.id
    And def petNombre = $.data.name
    And print "se tiene la mascota con el id: " + petId + " y nombre:  " + petNombre

    Given url 'http://localhost:3000/pets/' + petId
    And request
      """
      {
        "name": "Kittycita",
        "type": "Gato",
        "age": 8
      }
      """
    When method put
    Then status 200
    And match $.data.name == "Kittycita"

    And def petNombre2 = $.data.name
    And print "se actualizó mascota con el id: " + petId + " y nombre:  " + petNombre2

  Scenario: Borrar perro
    Given url 'http://localhost:3000/pets'
    And request
      """
      {
        "name": "Blacky",
        "type": "Perro",
        "age": 1
      }
      """
    And method post
    And status 201
    And def petId = $.data.id
    And def petNombre = $.data.name
    And print "se creó la mascota con el id: " + petId + " y nombre:  " + petNombre

    Given url 'http://localhost:3000/pets/' + petId
    When method delete
    Then status 204
    And print "se eliminó el perro con el id: " + petId
    And url 'http://localhost:3000/pets/' + petId
    And method get
    Then status 404
    And print "La mascota ya no esta"


  Scenario: Basic authentication

    * def credentials = "admin:password123"
    * def encoded = Java.type('java.util.Base64').encoder.encodeToString(credentials.getBytes())

    #porque la ruta es http://localhost:3000/protected-basic
    Given url "http://localhost:3000"
    And path "protected-basic"
    And header Authorization = 'Basic ' + encoded
    When method get
    Then status 200


  Scenario: Ingresar con token

    Given url baseURL
    And path "login"
    And request
      """
      {
      "username" : "automation",
      }
      """
    When method post
    Then status 200
    And def tokenUsuario = $.data.accessToken

    And path "protected-bearer"
    And header Authorization = "Bearer " + tokenUsuario
    When method get
    Then status 200
    And match response == 'Hello automation, you have accessed a protected endpoint!'

    * print response

  Scenario Outline: Outline Crear nuevo perro

    Given url baseURL
    And path "pets"
    And request
      """
      {
        "name": "#(name)",
        "type": "#(type)",
        "age": "#(parseInt(age))"
      }
      """
    When method post
    Then status 201
    And def petId = $.data.id
    And print petId

    Examples:
    | name | type   | age |
      | palito| Perro  | 4  |
      | monchito| loro  | 7  |
      | ginger| gato  | 5  |

  Scenario Outline: Create a new pet with <description>
    Given url baseURL
    And path "pets"

    And request
      """
      {
        "name": "<name>",
        "type": "<type>",
        "age": <age>
      }
      """
    When method post
    Then status <expectedStatus>
    And match $.message contains "<expectedMessage>"

    Examples:
      | name              | type  | age | description        | expectedStatus | expectedMessage |
      | Bluey 1 hhhhhdhdhhd | Perro | 1   | long name        | 201            | Pet created     |
      | Bluey 2 !!!       | Gato  | 2   | invalid characters | 201            | Pet created     |


  Scenario: Create a new dog reading an external file
    Given url baseURL
    And path "pets"
    * def createANewPetRequest = read('classpath:request/createANewPet.json')
    * def successfulPetCreationResponse = read('classpath:response/successfulPetCreationResponse.json')

    And request createANewPetRequest
    When method post
    Then status 201
    And match $.message contains "Pet created"
    And match response == successfulPetCreationResponse