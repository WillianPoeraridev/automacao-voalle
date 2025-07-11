*** Settings ***
Library    Dialogs
Library    SeleniumLibrary

*** Keywords ***
Obter CPF do Cliente
    [Documentation]    Exibe uma caixa de diálogo para o usuário digitar o CPF
    ...    e retorna o valor digitado.
    ${cpf}=    Get Value From User    message=Digite o CPF do cliente:
    RETURN    ${cpf}

Buscar Cliente no Voalle e Obter Nome
    [Arguments]    ${cpf}
    [Documentation]    Abre o Chrome com um perfil dedicado, busca um cliente e retorna o nome.

    # ABORDAGEM CORRETA E FINAL:
    # Usamos o Open Browser com o perfil dedicado.
    Open Browser    about:blank    browser=chrome    options=add_argument("--user-data-dir=C:/RPA_Profile")
    
    # CORREÇÃO FINAL: Usamos 'Set Selenium Timeout' para definir o tempo de espera
    # para keywords como 'Wait Until...'. Agora o robô realmente esperará 30 segundos.
    Set Selenium Timeout    30s
    
    Maximize Browser Window
    Go To    https://erp.fenixwireless.com.br/SearchPeople
    
    Wait Until Element Is Visible    id=search
    Input Text    id=search    ${cpf}
    Press Keys    id=search    ENTER
    Wait Until Element Is Visible    xpath=(//p[contains(@class, 'MuiTypography-color-primary')]/b)[1]
    ${nome_cliente}=    Get Text    xpath=(//p[contains(@class, 'MuiTypography-color-primary')]/b)[1]
    RETURN    ${nome_cliente}

*** Test Cases ***
Cenário 1: Consultar Cliente
    ${cpf_digitado}=    Obter CPF do Cliente
    ${nome_capturado}=    Buscar Cliente no Voalle e Obter Nome    ${cpf_digitado}
    Log To Console    CPF: ${cpf_digitado} | Nome Capturado: ${nome_capturado}
    # A linha abaixo está comentada para podermos fazer o login manual na primeira vez.
    # Close Browser
