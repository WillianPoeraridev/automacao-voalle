import os
import zipfile
from dotenv import load_dotenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
import pyperclip

class CustomLibrary:
    def __init__(self):
        load_dotenv()

    def publicar_evidencias_no_gist(self, caminho_da_pasta_de_debug, descricao_do_gist):
        username = os.getenv("GITHUB_USERNAME")
        token = os.getenv("GITHUB_GIST_TOKEN")
        if not (username and token):
            raise Exception("ERRO: Credenciais não encontradas no .env")

        print(f"INFO: Publicando Gist com a descrição: '{descricao_do_gist}'")

        driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
        wait = WebDriverWait(driver, 20)

        try:
            # Login e Navegação
            driver.get("https://gist.github.com")
            wait.until(EC.element_to_be_clickable((By.LINK_TEXT, "Sign in"))).click()
            wait.until(EC.visibility_of_element_located((By.ID, "login_field"))).send_keys(username)
            driver.find_element(By.ID, "password").send_keys(token)
            driver.find_element(By.NAME, "commit").click()
            driver.get("https://gist.github.com")
            print("SUCESSO: Login realizado!")

            # Preenchendo a Descrição
            description_field = wait.until(EC.visibility_of_element_located((By.NAME, "gist[description]")))
            description_field.send_keys(descricao_do_gist)

            # --- LÓGICA ATUALIZADA PARA UPLOAD DE MÚLTIPLOS ARQUIVOS ---
            
            # Pega dinamicamente todos os arquivos da pasta de debug
            arquivos_para_upload = [f for f in os.listdir(caminho_da_pasta_de_debug) if os.path.isfile(os.path.join(caminho_da_pasta_de_debug, f))]
            print(f"INFO: Arquivos a serem publicados: {arquivos_para_upload}")

            for index, nome_arquivo in enumerate(arquivos_para_upload):
                caminho_completo = os.path.join(caminho_da_pasta_de_debug, nome_arquivo)
                
                with open(caminho_completo, 'r', encoding='utf-8', errors='ignore') as f:
                    conteudo_arquivo = f.read()

                print(f"INFO: Preenchendo o arquivo {index + 1}: '{nome_arquivo}'...")

                if index > 0:
                    driver.find_element(By.XPATH, "//button[contains(., 'Add file')]").click()

                campos_nome_arquivo = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, "input.js-gist-filename")))
                campos_nome_arquivo[-1].send_keys(nome_arquivo)

                pyperclip.copy(conteudo_arquivo)
                
                campos_de_codigo = driver.find_elements(By.CLASS_NAME, "CodeMirror")
                actions = ActionChains(driver)
                actions.move_to_element(campos_de_codigo[-1]).click().key_down(Keys.CONTROL).send_keys('v').key_up(Keys.CONTROL).perform()

            print("SUCESSO: Todos os arquivos foram preenchidos no Gist.")

            wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'Create secret gist')]"))).click()
            
            wait.until(lambda d: "gist.github.com" in d.current_url and username in d.current_url)
            url_do_gist = driver.current_url
            print(f"SUCESSO: Gist publicado em: {url_do_gist}")

            return url_do_gist

        finally:
            driver.quit()