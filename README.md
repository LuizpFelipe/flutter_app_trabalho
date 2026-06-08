# Sistema de Gestão de Produção - Frontend (Flutter)

Este repositório contém a implementação do cliente mobile desenvolvido em Flutter para o Sistema de Gestão de Produção. O aplicativo permite a gestão de receitas, cadastro de ingredientes e automação do cálculo de insumos para produção em larga escala.

## Visão Geral

O projeto foi desenvolvido para atender cozinhas profissionais, focando na padronização de dados e eficiência operacional. A interface interage com uma API RESTful para gerenciar o estado da produção e garantir a integridade das fichas técnicas.

## Arquitetura e Padrões

O projeto adota padrões de arquitetura de software para garantir escalabilidade e manutenibilidade:

* Gerenciamento de Estado: Provider (implementação do padrão Observer).
* Arquitetura de Dados: Baseada em Modelos de Transferência (DTOs) que espelham a estrutura do banco de dados relacional.
* Estrutura de Código: Organização modular, separando a lógica de negócio (Providers) das interfaces visuais (Screens e Components).
* Comunicação: Consumo de serviços assíncronos via pacotes de requisição HTTP (ex: http ou dio).

## Funcionalidades Principais

* Gestão de Receitas: Cadastro, visualização e edição de fichas técnicas.
* Cadastro de Ingredientes: Interface para gerenciamento de insumos com suporte a normalização de dados.
* Painel de Produção: Seleção dinâmica de receitas, definição de quantidades e cálculo de escala de produção.
* Gerador de Lista de Compras: Processamento automático dos insumos necessários, agrupando quantidades e convertendo unidades de medida (gramas para quilogramas, ml para litros).
* Interface Reativa: Atualização em tempo real dos componentes da interface sempre que o estado da produção for alterado.

## Estrutura do Projeto

* /lib
* /components: Widgets reutilizáveis (cards, modais, campos de formulário).
* /providers: Gerenciadores de estado (lógica de negócio e fluxo de dados).
* /screens: Telas principais da aplicação (interface do utilizador).
* /services: Classes responsáveis pela comunicação com a API REST.
* /models: Definição das classes de dados (entidades do sistema).



## Pré-requisitos

Para rodar este projeto, é necessário ter o ambiente Flutter configurado:

* Flutter SDK (versão estável mais recente).
* Dart (compatível com a versão do Flutter).
* Dependências listadas no arquivo pubspec.yaml.

## Instalação

1. Clone o repositório:
git clone [git@github.com:LuizpFelipe/flutter_app_trabalho.git]
2. Instale as dependências:
flutter pub get
3. Configure o arquivo de variáveis de ambiente (se necessário).
4. Execute a aplicação:
flutter run

## Contribuição

Este projeto segue padrões de código limpo (Clean Code). Ao contribuir, certifique-se de:

1. Manter a lógica de negócio separada da interface visual.
2. Utilizar os Providers para qualquer alteração de estado.
3. Seguir a estrutura de pastas estabelecida.

---

Este documento serve como referência técnica para o desenvolvimento e manutenção da interface Flutter do projeto.