# Vidal Transportes

Este repositório, no estado atual, **contém documentação técnica** da solução Vidal Transportes (não contém ainda o código-fonte do app Flutter nem dos serviços de backend).

## Documentos principais

- [Arquitetura da Solução](docs/arquitetura-vidal-transportes.md)
- [Status de Teste do App](docs/teste-do-app.md)

## Objetivo

Consolidar em um único lugar as decisões técnicas e operacionais do ecossistema:

- aplicativo Flutter (Android/iOS),
- serviços Firebase,
- microsserviços em Cloud Run,
- segurança e governança GCP,
- observabilidade, custos e DevOps multiambiente.

## Status do repositório

- ✅ Documentação de arquitetura disponível.
- ⚠️ Código executável do app ainda não versionado neste repositório.

## Como testar o app (quando o código for adicionado)

1. Instalar Flutter e toolchains Android/iOS.
2. Configurar Firebase (`flutterfire configure`) com projeto de desenvolvimento.
3. Executar:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter run`
