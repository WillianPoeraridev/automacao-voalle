*** Settings ***
Library    Process
Library    OperatingSystem
Library    DateTime
Library    CustomLibrary.py

*** Variables ***
${ROBO_ALVO}    atendimento_cliente.robot

*** Test Cases ***
Executar e Capturar Resultado do Robô Alvo
    [Documentation]    Executa o robô alvo. Se falhar, coleta e (futuramente) publica as evidências.

    ${resultado}=    Run Process
    ...    robot ${ROBO_ALVO}
    ...    shell=True
    ...    stdout=PIPE
    ...    stderr=PIPE

    Run Keyword If    '${resultado.rc}' != '0'    Coletar e Publicar Evidências    ${resultado}

*** Keywords ***
Coletar e Publicar Evidências
    [Arguments]    ${resultado_da_falha}

    Log To Console    FALHA DETECTADA!

    # 1. Apenas coleta os arquivos
    ${timestamp}=       Get Current Date    result_format=%Y-%m-%d_%H-%M-%S
    ${nome_da_pasta}=   Set Variable    debug_${timestamp}
    ${pasta_destino}=   Set Variable    ${CURDIR}${/}reports${/}${nome_da_pasta}
    Create Directory    ${pasta_destino}
    Create File         ${pasta_destino}${/}erro_terminal.txt    ${resultado_da_falha.stderr}
    Copy File           ${ROBO_ALVO}    ${pasta_destino}${/}${ROBO_ALVO}
    Run Keyword And Ignore Error    Copy File    log.html      ${pasta_destino}${/}log.html
    Run Keyword And Ignore Error    Copy File    report.html   ${pasta_destino}${/}report.html
    
   # ... (parte de coleta de arquivos que já funciona)
    Log To Console      Evidências coletadas em: ${pasta_destino}

    # 2. Publica as evidências
    Log To Console    Iniciando a publicação do Gist...
    # Criando o título dinâmico, como você sugeriu!
    ${titulo_do_gist}=    Set Variable    Erro em ${ROBO_ALVO} - ${timestamp}

    # Passando o título para a nossa keyword
    ${link_final}=    Publicar Evidencias No Gist    ${pasta_destino}    ${titulo_do_gist}
    Log To Console    Processo de publicação finalizado. Status: ${link_final}