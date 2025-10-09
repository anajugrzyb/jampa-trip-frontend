# 🏖️ Jampa Trip - Frontend Flutter

Aplicativo móvel para turismo em João Pessoa, desenvolvido em Flutter com autenticação JWT integrada ao backend REST API.

## 🚀 Funcionalidades

### 🔐 Sistema de Autenticação JWT
- **Login/Registro** de clientes e empresas
- **Renovação automática** de tokens (access + refresh)
- **Armazenamento seguro** com FlutterSecureStorage
- **Proteção de rotas** com AuthGuard middleware
- **Persistência de sessão** ao reabrir o app

### 👥 Tipos de Usuário
- **Clientes**: Buscar e reservar passeios
- **Empresas**: Gerenciar passeios e reservas

### 🎯 Funcionalidades Principais
- Busca de passeios turísticos
- Sistema de reservas
- Pagamentos (PIX e cartão)
- Perfil do usuário
- Gerenciamento de passeios (empresas)

## 🛠️ Tecnologias

- **Flutter** 3.7.2+
- **Provider** - Gerenciamento de estado
- **HTTP** - Cliente REST API
- **FlutterSecureStorage** - Armazenamento seguro
- **JWT Decode** - Decodificação de tokens

## 📱 Estrutura do Projeto

```
.
├── android/             # Configurações Android
├── ios/                 # Configurações iOS
├── lib/                 # Código fonte Flutter
│   ├── assets/          # Recursos (imagens, fontes)
│   ├── middleware/      # Middleware de proteção
│   ├── models/          # Modelos de dados
│   ├── pages/           # Páginas da aplicação
│   ├── providers/       # Gerenciamento de estado
│   ├── services/        # Serviços de API
│   └── utils/           # Utilitários
├── test/                # Testes unitários
├── web/                 # Configurações Web
├── windows/             # Configurações Windows
├── linux/               # Configurações Linux
├── macos/               # Configurações macOS
├── pubspec.yaml         # Dependências do projeto
└── README.md
```

## 🔧 Configuração

### Pré-requisitos
- Flutter SDK 3.7.2+
- Dart SDK
- Backend JWT rodando em `http://localhost:1450`

### Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd jampa-trip-frontend
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o backend**
- Certifique-se de que o backend está rodando em `http://localhost:1450`
- O backend deve implementar os endpoints JWT especificados

4. **Execute o app**
```bash
flutter run
```

## 🔐 Autenticação JWT

### Endpoints da API
- `POST /jampa-trip/api/v1/login` - Login
- `POST /jampa-trip/api/v1/refresh` - Renovação de tokens
- `POST /jampa-trip/api/v1/clients` - Registro de cliente
- `POST /jampa-trip/api/v1/companies` - Registro de empresa

### Fluxo de Autenticação
1. **Login** → Recebe access_token (15min) + refresh_token (7 dias)
2. **Requisições** → Header `Authorization: Bearer <token>`
3. **Renovação** → Automática quando token expira
4. **Logout** → Limpa todos os tokens

### Segurança
- ✅ Tokens armazenados com criptografia
- ✅ Renovação automática de tokens
- ✅ Interceptors HTTP para adicionar Bearer token
- ✅ Proteção de rotas com AuthGuard
- ✅ Limpeza de sessão em logout

## 📋 Funcionalidades por Tipo de Usuário

### 👤 Cliente
- Buscar passeios disponíveis
- Fazer reservas
- Gerenciar perfil
- Histórico de reservas
- Pagamentos

### 🏢 Empresa
- Criar e gerenciar passeios
- Visualizar reservas
- Estatísticas de vendas
- Gerenciar perfil da empresa

## 🎨 Interface

- **Design moderno** com tema azul marinho
- **Loading states** durante requisições
- **Error handling** com mensagens amigáveis
- **Responsivo** para diferentes tamanhos de tela
- **Navegação intuitiva** entre telas

## 🔄 Gerenciamento de Estado

O app utiliza **Provider** para gerenciamento de estado global:

- **AuthProvider**: Estado de autenticação
- **Loading states**: Indicadores visuais
- **Error handling**: Tratamento de erros
- **Persistência**: Sessão mantida entre sessões

## 🛡️ Proteção de Rotas

Todas as páginas privadas são protegidas com **AuthGuard**:

- Verificação automática de autenticação
- Redirecionamento para login se não autenticado
- Loading states durante verificação
- Error handling para falhas de autenticação

## 📱 Páginas Principais

### Públicas
- **LoginPage**: Autenticação de usuários
- **RegisterPage**: Cadastro de clientes
- **RegisterCompanyPage**: Cadastro de empresas

### Protegidas (Clientes)
- **HomePage**: Página inicial com busca
- **AccountPage**: Perfil do cliente
- **TourListPage**: Lista de passeios
- **ReservationPage**: Fazer reservas
- **PaymentPage**: Métodos de pagamento

### Protegidas (Empresas)
- **AccountCompanyPage**: Perfil da empresa
- **MyToursPage**: Gerenciar passeios
- **AddTourPage**: Criar novos passeios

## 🚀 Como Executar

1. **Inicie o backend** (deve estar rodando em `localhost:1450`)
2. **Execute o Flutter**:
```bash
flutter run
```
3. **Teste o fluxo**:
   - Cadastre um cliente ou empresa
   - Faça login
   - Navegue pelas funcionalidades

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
