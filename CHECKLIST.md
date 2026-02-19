# ✅ Checklist de Deploy - FeedbackHub

Use este checklist para garantir que todos os passos foram executados corretamente.

---

## 📋 Fase 1: Preparação do Ambiente

- [ ] Java 21 instalado (`java -version`)
- [ ] Maven 3.8+ instalado (`mvn -version`)
- [ ] Azure CLI instalado (`az --version`)
- [ ] Git configurado
- [ ] Conta Azure ativa com créditos
- [ ] Login no Azure realizado (`az login`)

---

## ☁️ Fase 2: Provisionamento Azure

### Resource Group
- [ ] Resource Group criado: `feedbackhub-rg`
- [ ] Região selecionada: `eastus` ou `brazilsouth`

### SQL Database
- [ ] SQL Server criado
- [ ] Database `feedbackhub` criado (Serverless)
- [ ] Auto-pause configurado (60 min)
- [ ] Firewall configurado (Azure Services)
- [ ] Firewall configurado (Seu IP local)
- [ ] Credenciais anotadas (usuário/senha)

### Storage
- [ ] Storage Account criado
- [ ] Queue `feedback-urgencia-queue` criada
- [ ] Connection String obtida

### Function App
- [ ] Function App criado
- [ ] Runtime: Java 21
- [ ] Functions Version: 4.x
- [ ] OS: Linux
- [ ] Application Insights vinculado

### Application Insights
- [ ] Application Insights criado
- [ ] Instrumentation Key obtida

### Variáveis de Ambiente
- [ ] `DB_URL` configurada
- [ ] `DB_USERNAME` configurada
- [ ] `DB_PASSWORD` configurada
- [ ] `AZURE_STORAGE_CONNECTION_STRING` configurada
- [ ] `SENDGRID_API_KEY` configurada (pode ser depois)
- [ ] `SENDGRID_FROM_EMAIL` configurada (pode ser depois)
- [ ] `ADMIN_EMAILS` configurada (pode ser depois)
- [ ] `REPORT_EMAILS` configurada (pode ser depois)

### Arquivo de Credenciais
- [ ] `azure-credentials.txt` gerado
- [ ] Credenciais salvas em local seguro
- [ ] `azure-credentials.txt` adicionado ao `.gitignore`

---

## 📧 Fase 3: Configuração SendGrid

- [ ] Conta SendGrid criada (plano Free)
- [ ] E-mail de cadastro verificado
- [ ] Remetente único verificado (Single Sender)
- [ ] API Key gerada
- [ ] API Key testada (envio de e-mail teste)
- [ ] API Key configurada no Function App
- [ ] E-mails de administradores configurados
- [ ] E-mails de relatórios configurados

---

## 🔨 Fase 4: Build e Deploy

### Build Local
- [ ] `mvn clean package` executado com sucesso
- [ ] JAR gerado em `target/feedbackhub-1.0.0.jar`
- [ ] Sem erros de compilação
- [ ] Todas as classes compiladas

### Deploy Azure
- [ ] `mvn azure-functions:deploy` executado
- [ ] Deploy concluído sem erros
- [ ] 3 funções deployadas com sucesso:
  - [ ] `receberAvaliacao`
  - [ ] `notificarUrgencia`
  - [ ] `gerarRelatorioSemanal`

### Verificação no Portal
- [ ] Portal Azure acessado
- [ ] Resource Group aberto
- [ ] Function App mostra 3 funções
- [ ] Status: Running

---

## 🧪 Fase 5: Testes

### Obter Credenciais de Acesso
- [ ] URL do Function App obtida
- [ ] Function Key obtida

### Teste 1: Avaliação Positiva (nota 7-10)
- [ ] Request enviado
- [ ] Status 200 OK recebido
- [ ] JSON de resposta válido
- [ ] ID da avaliação retornado
- [ ] Urgência: POSITIVA
- [ ] **NÃO** deve enviar e-mail

### Teste 2: Avaliação Média (nota 4-6)
- [ ] Request enviado
- [ ] Status 200 OK recebido
- [ ] Urgência: MEDIA
- [ ] **NÃO** deve enviar e-mail

### Teste 3: Avaliação Crítica (nota 0-3)
- [ ] Request enviado
- [ ] Status 200 OK recebido
- [ ] Urgência: CRITICA
- [ ] **DEVE** enviar e-mail de urgência
- [ ] E-mail recebido na caixa de entrada
- [ ] E-mail contém:
  - [ ] Descrição da avaliação
  - [ ] Nota
  - [ ] Urgência (CRITICA)
  - [ ] Data/hora

### Teste 4: Validações
- [ ] Request sem descrição retorna erro 400
- [ ] Request sem nota retorna erro 400
- [ ] Request com nota < 0 retorna erro 400
- [ ] Request com nota > 10 retorna erro 400
- [ ] Request com descrição muito longa retorna erro 400

### Teste 5: Relatório Semanal
- [ ] Função `gerarRelatorioSemanal` invocada manualmente
- [ ] E-mail de relatório recebido
- [ ] Relatório contém:
  - [ ] Período (data início - data fim)
  - [ ] Total de avaliações
  - [ ] Média geral
  - [ ] Distribuição por urgência
  - [ ] Avaliações por dia
  - [ ] Lista de avaliações críticas

### Teste 6: Queue Processing
- [ ] Mensagem adicionada à queue após avaliação crítica
- [ ] Função `notificarUrgencia` processou a mensagem
- [ ] Mensagem removida da queue após processamento
- [ ] Avaliação marcada como `notificada = true` no banco

---

## 📊 Fase 6: Monitoramento

### Logs
- [ ] `az functionapp log tail` mostra logs em tempo real
- [ ] Logs das 3 funções visíveis
- [ ] Sem erros críticos nos logs

### Application Insights
- [ ] Portal do Application Insights acessado
- [ ] Live Metrics mostra dados
- [ ] Execuções registradas
- [ ] Dependências rastreadas:
  - [ ] SQL Database
  - [ ] Storage Queue
  - [ ] SendGrid (HTTP)
- [ ] Sem falhas críticas

### Portal Azure
- [ ] Function App > Monitor mostra execuções
- [ ] Gráficos de execução/segundo
- [ ] Taxa de sucesso > 95%
- [ ] Tempo médio de resposta < 2s

---

## 🔒 Fase 7: Segurança

- [ ] SQL Database usa SSL/TLS
- [ ] Firewall do SQL restrito
- [ ] Function Keys habilitadas
- [ ] HTTPS obrigatório nas Functions
- [ ] Variáveis de ambiente protegidas (não no código)
- [ ] Credenciais não commitadas no Git
- [ ] `.gitignore` configurado corretamente

---

## 📹 Fase 8: Preparação do Vídeo

### Demonstração do Portal Azure
- [ ] Resource Group com todos os recursos
- [ ] SQL Database (configuração Serverless)
- [ ] Storage Queue
- [ ] Function App (3 funções)
- [ ] Application Insights (dashboards)

### Demonstração da API
- [ ] Postman/Insomnia ou cURL preparado
- [ ] Exemplos de requests salvos
- [ ] 3 tipos de avaliações testadas ao vivo
- [ ] Resposta JSON formatada

### Demonstração de E-mails
- [ ] E-mail de urgência mostrado
- [ ] Conteúdo formatado (HTML)
- [ ] Relatório semanal mostrado
- [ ] Estatísticas visíveis

### Demonstração do Código
- [ ] Arquitetura MVC explicada
- [ ] Separação de responsabilidades
- [ ] 3 Azure Functions (responsabilidade única)
- [ ] Configuração do Spring Boot
- [ ] application.yml

### Demonstração do Monitoramento
- [ ] Logs em tempo real
- [ ] Application Insights
- [ ] Métricas de performance
- [ ] Rastreamento de dependências

### Demonstração da Configuração
- [ ] Variáveis de ambiente (sem expor valores!)
- [ ] Configurações de segurança
- [ ] Firewall rules
- [ ] Queue configuration

---

## 📝 Fase 9: Documentação

- [ ] README.md atualizado
- [ ] FUNCTIONS.md completo
- [ ] AZURE_SETUP.md criado
- [ ] QUICKSTART-AZURE.md criado
- [ ] Diagramas de arquitetura
- [ ] Instruções de deploy
- [ ] Troubleshooting guide
- [ ] Credenciais documentadas (em local seguro)

---

## 📦 Fase 10: Repositório

- [ ] Código commitado
- [ ] `.gitignore` atualizado
- [ ] Credenciais não incluídas
- [ ] README principal atualizado
- [ ] Documentação incluída
- [ ] Scripts de setup incluídos
- [ ] Licença incluída
- [ ] Repositório público no GitHub

---

## 🎯 Fase 11: Validação Final

### Requisitos do Tech Challenge
- [ ] ✅ Aplicação em ambiente cloud
- [ ] ✅ Serverless implementado (Azure Functions)
- [ ] ✅ Mínimo 2 funções (temos 3)
- [ ] ✅ Responsabilidade única respeitada
- [ ] ✅ Recebe feedbacks (POST /avaliacao)
- [ ] ✅ Notificações automáticas (avaliações críticas)
- [ ] ✅ Relatório semanal (timer trigger)
- [ ] ✅ Banco de dados configurado (Azure SQL)
- [ ] ✅ Deploy automatizado (Maven plugin)
- [ ] ✅ Monitoramento configurado (App Insights)
- [ ] ✅ Segurança implementada
- [ ] ✅ Governança de acesso (RBAC, Firewall)

### Código
- [ ] ✅ Arquitetura MVC
- [ ] ✅ Spring Boot configurado
- [ ] ✅ JPA/Hibernate funcionando
- [ ] ✅ Validações implementadas
- [ ] ✅ Tratamento de erros
- [ ] ✅ Logs informativos
- [ ] ✅ Código documentado

### Funcionalidades
- [ ] ✅ Recepção de avaliações
- [ ] ✅ Classificação de urgência
- [ ] ✅ Persistência no banco
- [ ] ✅ Fila de mensagens
- [ ] ✅ Notificações por e-mail
- [ ] ✅ Relatórios semanais
- [ ] ✅ Estatísticas calculadas

---

## 🎥 Fase 12: Gravação do Vídeo

### Estrutura Sugerida (10-15 min)

1. **Introdução (1 min)**
   - [ ] Apresentação do projeto
   - [ ] Objetivos do Tech Challenge
   - [ ] Tecnologias utilizadas

2. **Arquitetura (2 min)**
   - [ ] Diagrama da solução
   - [ ] Componentes Azure
   - [ ] Fluxo de dados
   - [ ] Separação de responsabilidades

3. **Portal Azure (3 min)**
   - [ ] Resource Group
   - [ ] SQL Database (Serverless)
   - [ ] Storage Queue
   - [ ] Function App (3 funções)
   - [ ] Application Insights

4. **Demonstração da API (3 min)**
   - [ ] Avaliação positiva
   - [ ] Avaliação média
   - [ ] Avaliação crítica (mostrar e-mail)
   - [ ] Validações

5. **E-mails (2 min)**
   - [ ] Notificação de urgência
   - [ ] Relatório semanal

6. **Monitoramento (2 min)**
   - [ ] Logs em tempo real
   - [ ] Application Insights
   - [ ] Métricas

7. **Código (2 min)**
   - [ ] Estrutura MVC
   - [ ] Azure Functions
   - [ ] Configurações

8. **Conclusão (1 min)**
   - [ ] Requisitos atendidos
   - [ ] Próximos passos
   - [ ] Repositório GitHub

---

## 🚀 Status Final

**Data de conclusão**: ___/___/______

**Todos os itens verificados?** [ ] SIM [ ] NÃO

**Deploy funcionando?** [ ] SIM [ ] NÃO

**Vídeo gravado?** [ ] SIM [ ] NÃO

**Repositório público?** [ ] SIM [ ] NÃO

**Pronto para entrega?** [ ] SIM [ ] NÃO

---

## 📞 Problemas Encontrados

Liste aqui qualquer problema encontrado durante o processo:

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

---

## 💡 Melhorias Futuras (Opcional)

- [ ] Autenticação de usuários (Azure AD)
- [ ] API Management
- [ ] Cosmos DB (NoSQL)
- [ ] Container Instances
- [ ] CI/CD com GitHub Actions
- [ ] Testes automatizados
- [ ] Frontend React/Angular
- [ ] GraphQL API
- [ ] WebSockets para notificações real-time

---

**Boa sorte! 🎉**

