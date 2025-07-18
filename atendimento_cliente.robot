*** Settings ***
Library           Dialogs
Library           SeleniumLibrary
#Suite Teardown    Close Browser  # Desativado temporariamente para facilitar a depuração

*** Test Cases ***
Cenário 1: Consultar Cliente e Decidir Ação
    [Documentation]    Busca um cliente, permite a verificação manual de pendências e age conforme a decisão.
    ${cpf_digitado}=    Obter CPF do Cliente
    ${nome_capturado}=    Buscar Cliente no Voalle e Obter Nome    ${cpf_digitado}
    Acessar Detalhes do Cliente
    Verificar Pendencias Financeiras
    Verificar Pendências Manualmente    ${nome_capturado}
    Selecionar Contrato, Serviço e Iniciar Alteração
    Clicar No Botao De Acoes Do Servico
    
    # Pausa para a seleção manual do plano, garantindo que o modal apareça
    Pause Execution    Selecione o plano na lista e clique em SELECIONAR. Depois clique OK aqui.

    # A keyword agora é chamada no momento certo e retorna os planos
    ${plano_antigo}    ${plano_novo}=    Aguardar Confirmacao e Acessar Faturamento

*** Keywords ***
Obter CPF do Cliente
    [Documentation]    Exibe uma caixa de diálogo para o usuário digitar o CPF e retorna o valor digitado.
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
    Input Text    ID=search    ${cpf}
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
    ${seletor_financeiro}=    Set Variable    xpath=//li[@role="menuitem" and .//p[normalize-space(text())='Financeiro']]
    Wait Until Element Is Visible    ${seletor_financeiro}
    Click Element    ${seletor_financeiro}

Verificar Pendências Manualmente
    [Arguments]    ${nome_do_cliente}
    [Documentation]    Exibe um pop-up para o usuário verificar manualmente e decidir o próximo passo.
    ${resposta}=    Get Selection From User
    ...    Existem pendências financeiras para este cliente?
    ...    Sim, existem pendências
    ...    Não, tudo certo
    IF    '${resposta}' == 'Sim, existem pendências'
        Abrir e Logar no PipeRun
    ELSE
        Navegar para Dashboard de Contratos    ${nome_do_cliente}
    END

Abrir e Logar no PipeRun
    [Documentation]    Abre o PipeRun em uma nova aba e realiza o login.
    Execute Javascript    window.open('https://rapidanet.cxm.pipe.run/agent#')
    Switch Window    NEW
    Wait Until Page Contains Element    id:login-email    timeout=20s
    # Lembre-se de usar o Vault ou variáveis de ambiente para segurança!
    ${USUARIO_PIPERUN}=    Set Variable    seu-email@dominio.com
    ${SENHA_PIPERUN}=      Set Variable    sua-senha-aqui
    Input Text    id:login-email       ${USUARIO_PIPERUN}
    Input Text    id:login-password    ${SENHA_PIPERUN}
    Click Button    xpath=//button[@type='submit']

Navegar para Dashboard de Contratos
    [Arguments]    ${nome_do_cliente}
    [Documentation]    Navega para a tela de contratos, confirma e busca pelo nome do cliente.
    Go To    https://erp.fenixwireless.com.br/contract_dashboard#contracts-maintenance
    ${seletor_botao_confirmar}=    Set Variable    xpath=//button[span[text()='Confirmar']]
    Wait Until Element Is Visible    ${seletor_botao_confirmar}    timeout=15s
    Click Element    ${seletor_botao_confirmar}
    ${seletor_campo_busca}=    Set Variable    css=div#contracts-maintenance-table_filter input
    Wait Until Element Is Visible    ${seletor_campo_busca}    timeout=15s
    Input Text    ${seletor_campo_busca}    ${nome_do_cliente}

Selecionar Contrato, Serviço e Iniciar Alteração
    [Documentation]    Clica no primeiro contrato da lista, acessa serviços e inicia a alteração.
    Wait Until Element Is Visible    xpath=//table[@id='contracts-maintenance-table']//tbody/tr[1]    15s
    Click Element    xpath=//table[@id='contracts-maintenance-table']//tbody/tr[1]
    Wait Until Element Is Visible    id=serviceTab    15s
    Click Element    id=serviceTab
    Wait Until Element Is Visible    xpath=//table[@id='contract-services-table']/tbody/tr[1]    15s
    Click Element    xpath=//table[@id='contract-services-table']/tbody/tr[1]
    Wait Until Element Is Visible    id=action-change-contract-items-react    15s
    Click Element    id=action-change-contract-items-react

Clicar No Botao De Acoes Do Servico
    [Documentation]    Clica no botão de ações (três pontos) que tem a tooltip 'Alterar'.
    ${seletor_botao_acoes}=    Set Variable    css:button[tooltip='Alterar']
    Wait Until Element Is Visible    ${seletor_botao_acoes}    timeout=15s
    Click Element    ${seletor_botao_acoes}

Aguardar Confirmacao e Acessar Faturamento
    [Documentation]    Espera o modal de confirmação, coleta os planos,
    ...                aguarda o clique em CONFIRMAR e abre a aba “Dados Faturamento”.

    # 1. Espera o modal aparecer (procura o botão CONFIRMAR)
    ${CONFIRM_MENSAL}=    Set Variable    xpath=//button[normalize-space(.)='CONFIRMAR']
    Wait Until Element Is Visible    ${CONFIRM_MENSAL}    timeout=5m

    # 2. Coleta os nomes dos planos via pop-up
    ${plano_antigo}=    Get Value From User    message=Digite ou cole o nome do PLANO A REMOVER:
    ${plano_novo}=      Get Value From User    message=Digite ou cole o nome do PLANO A ADICIONAR:

    # 3. Pausa para você clicar CONFIRMAR no modal
    Pause Execution    Clique em CONFIRMAR no Voalle. Depois clique em OK aqui.

    # 4. Aguarda o modal desaparecer
    Wait Until Element Is Not Visible    ${CONFIRM_MENSAL}    timeout=5m

    # 5. Abre a aba “Dados Faturamento”
    Click Element    css=li#invoiceDataTab

    # 6. Pop-up final
    Pause Execution    Clique OK para finalizar o robô.

    RETURN    ${plano_antigo}    ${plano_novo}