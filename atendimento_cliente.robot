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
    Open Browser    about:blank    browser=chrome    options=add_argument("--user-data-dir=C:/RPA_Profile")
    Set Selenium Timeout    30s
    Maximize Browser Window
    Go To    https://erp.fenixwireless.com.br/SearchPeople
    
    Wait Until Element Is Visible    id=search
    Input Text    id=search    ${cpf}
    Press Keys    id=search    ENTER
    
    Wait Until Element Is Visible    xpath=(//div[@role="row"]//b)[1]
    ${nome_cliente}=    Get Text    xpath=(//div[@role="row"]//b)[1]
    RETURN    ${nome_cliente}

Acessar Detalhes do Cliente
    [Documentation]    Na tela de resultados, clica no ícone de informações do cliente.
    ${seletor_icone_info}=    Set Variable    css:button[tooltip='Consultar informações da pessoa']
    Wait Until Element Is Visible    ${seletor_icone_info}
    Click Element    ${seletor_icone_info}

Verificar Pendencias Financeiras
    [Documentation]    Clica na aba Financeiro para analisar as faturas do cliente.
    # Este é o seletor que mira no "botão" (o item de menu <li>) e que funcionou.
    ${seletor_financeiro}=    Set Variable    xpath=//li[@role="menuitem" and .//p[normalize-space(text())='Financeiro']]
    Wait Until Element Is Visible    ${seletor_financeiro}
    Click Element    ${seletor_financeiro}

*** Test Cases ***
Cenário 1: Consultar Cliente
    ${cpf_digitado}=    Obter CPF do Cliente
    ${nome_capturado}=    Buscar Cliente no Voalle e Obter Nome    ${cpf_digitado}
    Acessar Detalhes do Cliente
    Verificar Pendencias Financeiras
    Log To Console    Acesso à área financeira do cliente ${nome_capturado} realizado.
    Pause Execution    Verifique se a aba Financeiro abriu corretamente.
    Close Browser
