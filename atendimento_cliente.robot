*** Settings ***
Library    Dialogs
Library    SeleniumLibrary

*** Keywords ***
Obter CPF do Cliente
    [Documentation]    Exibe uma caixa de diálogo para o usuário digitar o CPF
    ...    e retorna o valor digitado.

    ${cpf}=    Get Value From User    message=Digite o CPF do cliente:
    [Return]    ${cpf}

*** Test Cases ***
Cenário 1: Consultar Cliente
    ${cpf_digitado}=    Obter CPF do Cliente
    Log To Console    O CPF digitado pelo usuário foi: ${cpf_digitado}
