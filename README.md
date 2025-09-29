[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/0pdlt3gZ)
# Projeto CM Hospitais Parte 2

LINK DO VIDEO : https://www.youtube.com/watch?v=kNHRoCGcUlQ

# SNS App - Relatório de Projeto

Este documento detalha o desenvolvimento e a arquitetura da aplicação móvel "SNS App", criada para permitir a visualização de hospitais, seus detalhes, avaliações e tempos de espera, com funcionalidades offline e integração com APIs externas.

---

## 1. Dados dos Alunos

Nome: Akashpreet Singh  - Número: a22205953





---

## 2. Screenshots dos Ecrãs


* **DashBoard:**
  ![dashboard](https://github.com/user-attachments/assets/76a6831a-d550-4b5f-87e9-de3923524379)


* **Lista de Hospitais:**
  ![lista](https://github.com/user-attachments/assets/9ea2b316-fc43-404a-8536-53dd63fc5f2b)


* **Mapa de Hospitais:**
  ![mapa](https://github.com/user-attachments/assets/86b1273f-5d4a-442c-ba74-75592a33dadf)


* **Detalhes do Hospital:**
  ![detalhes com avaliacao](https://github.com/user-attachments/assets/133e5a96-9a1a-4a63-b9e1-3bb1054818bf)

  
* **Detalhes do Hospital com Tempos de Espera:**
  ![detalhes com tempo espera](https://github.com/user-attachments/assets/1d59e3ae-a302-4abc-a9a9-98198da82f34)


* **Pagina Avaliar:**
 ![pag avaliar](https://github.com/user-attachments/assets/973101b4-5299-4980-8423-14908769d836)



---

## 3. Funcionalidades Implementadas

As seguintes funcionalidades foram implementadas na aplicação, abrangendo do projeto:


* **Listagem de Hospitais**: A aplicação exibe uma lista de hospitais, mostrando o nome e indicando se possui serviço de urgência.
* **Detalhes do Hospital**: Ao selecionar um hospital da lista ou do mapa, o utilizador pode visualizar detalhes como nome, endereço, distrito, telefone, email e se possui emergência.
* **Integração com API Externa**: Os dados dos hospitais são obtidos a partir da API oficial (servicos.min-saude.pt/pds/api/tems/institution).
* **Exibição de Avaliações**: Embora não haja funcionalidade para adicionar avaliações, a estrutura para exibir avaliações associadas a um hospital está presente (`EvaluationReport` model e exibição na `Detalhes` page).


* **Visualização de Tempos de Espera (Triagem)**: Na tela de detalhes do hospital, é possível visualizar os tempos de espera para cada nível de triagem (Vermelho, Laranja, Amarelo, Verde, Azul), obtidos através da API (`servicos.min-saude.pt/pds/api/tems/standbyTime/$hospitalId`).
* **Armazenamento Local (Sqflite)**: Os dados dos hospitais são armazenados localmente utilizando `sqflite`, garantindo o acesso offline aos hospitais previamente carregados.
    * **Criação de Tabelas**: As tabelas `hospital`, `evaluations` e `waiting_times` são criadas na base de dados local.
    * **Inserção de Dados**: Hospitais e tempos de espera são inseridos na base de dados local.
    * **Recuperação de Dados**: Dados de hospitais, avaliações e tempos de espera são recuperados da base de dados local.
* **Sincronização de Dados**: A aplicação implementa lógica para sincronizar os dados dos hospitais da API para a base de dados local quando há conectividade e a base de dados local está vazia, ou periodicamente (implícito pela arquitetura do `SnsRepository`).
* **Mapa Interativo (Google Maps)**: Um ecrã dedicado (mapa.dart) exibe a localização dos hospitais em um mapa interativo, com marcadores clicáveis que levam aos detalhes do hospital.
* **Gerenciamento de Conectividade**: O `SnsRepository` verifica a conectividade à internet (`ConnectivityModule`) para decidir se obtém dados da API ou da base de dados local.
* **Injeção de Dependências (Provider)**: As dependências como `HttpSnsDataSource`, `SqfliteSnsDataSource` e `ConnectivityModule` são fornecidas e acessadas via `Provider`, o que facilita a testabilidade e a manutenção do código.

---

## 4. Previsão da Nota (Autoavaliação)


* **Nota autoavaliação:** [16]

---

## 5. Arquitetura da Aplicação

A arquitetura da aplicação segue os princípios de separação de responsabilidades e injeção de dependências, promovendo um código limpo, testável e de fácil manutenção. O design é influenciado pelo padrão Repository e o uso de Data Sources.

**Camadas Principais:**

* **Camada de UI (User Interface)**:
    * `listpage.dart`: Responsável por exibir a lista de hospitais.
    * `mapa.dart`: Responsável por exibir os hospitais no mapa.
    * `detalhespage.dart`: Exibe os detalhes de um hospital específico, incluindo avaliações e tempos de espera.
    * Estas páginas interagem com o `SnsRepository` para obter os dados necessários, sem conhecimento direto da origem dos dados (API ou DB local).

* **Camada de Repositório (`SnsRepository`)**:
    * Atua como uma abstração para a fonte de dados, desacoplando a lógica de negócio da camada de persistência.
    * Decide de qual `DataSource` (API ou DB local) obter os dados, baseando-se na conectividade à internet (verificada pelo `ConnectivityModule`).
    * Contém a lógica para sincronizar dados da API para a base de dados local.
    * Ex: `getAllHospitals()`, `getHospitalDetailById()`, `getHospitalWaitingTimes()`.

* **Camada de Data Sources (`SnsDataSource` - interface, `HttpSnsDataSource`, `SqfliteSnsDataSource`)**:
    * **`SnsDataSource` (abstract class)**: Define o contrato para as operações de dados.
    * **`HttpSnsDataSource`**: Implementa o `SnsDataSource` para interagir com a API externa (serviços.min-saude.pt). Utiliza um `HttpCliente` (não fornecido, mas inferido) para fazer as requisições HTTP.
    * **`SqfliteSnsDataSource`**: Implementa o `SnsDataSource` para interagir com a base de dados local `Sqflite`. Responsável por operações CRUD no banco de dados.
    * Esta separação permite que a lógica de acesso a dados seja trocada ou adicionada sem afetar as camadas superiores.

* **Camada de Modelos (`Hospital`, `EvaluationReport`, `WaitingTime`, `TriageLevel`)**:
    * Define as estruturas de dados (objetos de negócio) que representam as entidades da aplicação.
    * Inclui métodos `fromJson`/`fromMap` e `toMap` para facilitar a conversão entre objetos Dart e JSON/Mapas de base de dados.

* **Módulos de Utilitário/Infraestrutura**:
    * **`ConnectivityModule`**: Abstrai a lógica de verificação de conectividade de rede.
    * **`LocationModule`**: (Inferido pelo `mapa.dart`) Abstrai a lógica de obtenção da localização do utilizador.
    * **`HttpCliente`**: (Inferido pelo `http_sns_datasource.dart`) Classe para gerenciar requisições HTTP.

**Boas Práticas Utilizadas:**

1.  **Separação de Responsabilidades (SRP)**: Cada classe tem uma responsabilidade bem definida. Por exemplo, `SnsRepository` lida com a decisão da fonte de dados, enquanto os `DataSources` lidam com a comunicação específica (HTTP ou Sqflite). As páginas UI apenas exibem os dados.
2.  **Padrão Repository**: O `SnsRepository` centraliza as operações de dados, fornecendo uma API consistente para as camadas de UI e negócio, independentemente da origem dos dados. Isso facilita a troca de fontes de dados no futuro.
3.  **Abstração de Data Sources**: A interface `SnsDataSource` garante que tanto a API quanto a base de dados local sigam o mesmo contrato, permitindo que o `SnsRepository` trabalhe com qualquer implementação.
4.  **Injeção de Dependências (Provider)**: O uso do pacote `provider` no `main.dart` (inferido, pois os `DataSources` são acessados via `Provider.of<...>(context)`) permite que as dependências sejam fornecidas e gerenciadas de forma eficiente, facilitando a testabilidade e a escalabilidade.
5.  **Offline-First/Cache**: A implementação de `SqfliteSnsDataSource` e a lógica de sincronização no `SnsRepository` permitem que a aplicação funcione offline, proporcionando uma melhor experiência ao utilizador.
6.  **Modelagem de Dados**: As classes de modelo (`Hospital`, `EvaluationReport`, `WaitingTime`) são bem definidas com métodos para serialização/desserialização (`fromMap`, `toMap`, `fromJson`), garantindo a consistência dos dados.
7.  **Tratamento de Erros/Exceções**: A camada `HttpSnsDataSource` inclui tratamento básico de status codes HTTP.
8.  **Nomenclatura Clara**: As classes e métodos têm nomes descritivos que indicam claramente sua finalidade.

---

## 6. Link para o Vídeo de Apresentação

LINK DO VIDEO : https://www.youtube.com/watch?v=kNHRoCGcUlQ


---

## 7. Classes de Lógica de Negócio

As classes a seguir representam a lógica de negócio e os modelos de dados da aplicação:

### `Hospital`

* **Descrição:** Representa um hospital, com suas informações básicas, localização, e listas de avaliações e tempos de espera.
* **Atributos:**
    * `id`: `int` - Identificador único do hospital.
    * `name`: `String` - Nome do hospital.
    * `latitude`: `double` - Latitude da localização do hospital.
    * `longitude`: `double` - Longitude da localização do hospital.
    * `address`: `String` - Endereço do hospital.
    * `phoneNumber`: `int` - Número de telefone do hospital.
    * `email`: `String` - Endereço de email do hospital.
    * `district`: `String` - Distrito onde o hospital está localizado.
    * `distance`: `double?` - Distância do utilizador ao hospital (valor placeholder `0` inicialmente, pode ser calculado dinamicamente).
    * `rating`: `double` - Avaliação média do hospital (calculada a partir das avaliações).
    * `reports`: `List<EvaluationReport>` - Lista de avaliações recebidas pelo hospital.
    * `hasEmergency`: `bool` - Indica se o hospital possui serviço de emergência.
* **Métodos:**
    * `Hospital.fromMap(Map<String, dynamic> map)`: `factory constructor` - Converte um `Map` (de JSON da API ou base de dados) em um objeto `Hospital`.
    * `Map<String, dynamic> toMap()`: Converte o objeto `Hospital` em um `Map` para armazenamento em base de dados.
    * `List<EvaluationReport> getReports()`: Retorna a lista de relatórios de avaliação.
    * `void setReports(List<EvaluationReport> value)`: Define a lista de relatórios de avaliação.
    * `void insereAvaliacao(EvaluationReport avaliacao)`: Adiciona uma nova avaliação e recalcula a média de avaliação (`rating`).

### `EvaluationReport`

* **Descrição:** Representa uma avaliação de um hospital.
* **Atributos:**
    * `nomeHospital`: `String?` - Nome do hospital avaliado.
    * `valor`: `int` - Pontuação da avaliação (ex: 1 a 5 estrelas).
    * `dataHora`: `String?` - Data e hora da avaliação.
    * `nota`: `String?` - Texto da nota/comentário da avaliação.
* **Métodos:**
    * `EvaluationReport.fromDB(Map<String, dynamic> db)`: `factory constructor` - Converte um `Map` (de base de dados) em um objeto `EvaluationReport`.
    * `Map<String, dynamic> toDB()`: Converte o objeto `EvaluationReport` em um `Map` para armazenamento em base de dados.

### `WaitingTime`

* **Descrição:** Representa os tempos de espera para os diferentes níveis de triagem em um hospital.
* **Atributos:**
    * `red`: `TriageLevel` - Tempo de espera para triagem vermelha.
    * `orange`: `TriageLevel` - Tempo de espera para triagem laranja.
    * `yellow`: `TriageLevel` - Tempo de espera para triagem amarela.
    * `green`: `TriageLevel` - Tempo de espera para triagem verde.
    * `blue`: `TriageLevel` - Tempo de espera para triagem azul.
    * `lastUpdate`: `DateTime` - Data e hora da última atualização dos tempos de espera.
* **Métodos:**
    * `WaitingTime.fromJson(Map<String, dynamic> json)`: `factory constructor` - Converte um `Map` (de JSON da API) em um objeto `WaitingTime`.
    * `Map<String, dynamic> toMap({required int hospitalId})`: Converte o objeto `WaitingTime` em um `Map` para armazenamento em base de dados, associando-o a um `hospitalId`.

### `TriageLevel`

* **Descrição:** Uma classe auxiliar que representa o número de pacientes e o tempo de espera para um nível específico de triagem.
* **Atributos:**
    * `length`: `int` - Número de pacientes no nível de triagem.
    * `time`: `int` - Tempo de espera em minutos para o nível de triagem.
* **Métodos:**
    * `TriageLevel.fromJson(Map<String, dynamic> json)`: `factory constructor` - Converte um `Map` (de JSON da API) em um objeto `TriageLevel`.

### `SnsRepository`

* **Descrição:** Classe que orquestra o acesso aos dados, decidindo entre a fonte de dados HTTP (API) e a fonte de dados local (Sqflite) com base na conectividade. Também gerencia a sincronização de dados.
* **Atributos:**
    * `_httpSnsDataSource`: `SnsDataSource` - Instância do `HttpSnsDataSource`.
    * `_sqfliteSnsDataSource`: `SqfliteSnsDataSource` - Instância do `SqfliteSnsDataSource`.
    * `_connectivityModule`: `ConnectivityModule` - Instância para verificar a conectividade de rede.
* **Métodos:**
    * `_getDataSource()`: `Future<SnsDataSource>` - Método privado que retorna a `DataSource` apropriada (HTTP ou Sqflite) com base na conectividade.
    * `syncHospitalsToLocal()`: `Future<void>` - Sincroniza os hospitais da API para a base de dados local.
    * `getAllHospitals()`: `Future<List<Hospital>>` - Obtém todos os hospitais, utilizando a `DataSource` apropriada.
    * `getHospitalsByName(String name)`: `Future<List<Hospital>>` - Obtém hospitais filtrados por nome.
    * `getHospitalDetailById(int hospitalId)`: `Future<Hospital>` - Obtém os detalhes de um hospital específico, incluindo avaliações do DB local.
    * `attachEvaluation(int hospitalId, EvaluationReport report)`: `Future<void>` - Anexa uma avaliação a um hospital (atualmente implementado apenas no `SqfliteSnsDataSource` nos arquivos fornecidos).
    * `getHospitalWaitingTimes(int hospitalId)`: `Future<List<WaitingTime>>` - Obtém os tempos de espera de um hospital.
    * `insertWaitingTime(int hospitalId, dynamic waitingTime)`: `Future<void>` - Insere tempos de espera na base de dados local.

---

## 8. Fontes de Informação


* [Exemplo: Vídeo no YouTube - "Flutter Google Maps Tutorial | Location Tracking, Maps, Markers, Polylines, Directions API" - Para a implementação do Mapa.]
* [Exemplo.: ChatGPT - Para melhorar e ajustar Mapa.]
* [Youtube:https://www.youtube.com/watch?v=M7cOmiSly3Q&ab_channel=HussainMustafa]

---

