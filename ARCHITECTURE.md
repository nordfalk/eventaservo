# Arkitekturo - Eventa Servo

## Projekta Strukturo

```
eventaservo/
├── app/
│   ├── controllers/         # Kontrolistoj
│   │   ├── admin/           # Admin panelo
│   │   │   ├── dashboard_controller.rb
│   │   │   ├── events_controller.rb
│   │   │   ├── organizations_controller.rb
│   │   │   ├── users_controller.rb
│   │   │   └── ...
│   │   ├── api/              # API kontrolistoj
│   │   │   ├── v1/          # API v1 (malnova)
│   │   │   └── v2/          # API v2 (moderna)
│   │   ├── concerns/        # Kontrolistoj-concerns
│   │   ├── event/           # Event-rilataj kontrolistoj
│   │   ├── iloj/            # Ilaraj kontrolistoj
│   │   ├── users/           # Uzadministrado
│   │   └── webcal/          # Kalendara feedoj
│   │
│   ├── models/              # Modeloj (ActiveRecord)
│   │   ├── ahoy/            # Ahoy analitiko
│   │   ├── concerns/        # Model-concerns
│   │   ├── event/           # Event-rilataj modeloj
│   │   └── ...
│   │
│   ├── services/            # Servoj (business logic)
│   │   ├── backup/          # Backup servoj
│   │   ├── events/          # Event-servoj
│   │   ├── event_services/  # Event-rilataj servoj
│   │   ├── google_drive/    # Google Drive integriĝo
│   │   ├── housekeeping/    # Sistema konservado
│   │   ├── logs/            # Log-servoj
│   │   ├── time_zone/       # Timezone servoj
│   │   ├── users/           # User-servoj
│   │   └── user_services/   # User-rilataj servoj
│   │
│   ├── queries/             # Kverioj (read-only)
│   │   ├── events/          # Event-kverioj
│   │   ├── logs/            # Log-kverioj
│   │   ├── organizations/   # Organiza kverioj
│   │   └── users/           # User-kverioj
│   │
│   ├── jobs/                # Taskoj (Solid Queue)
│   │   └── logs/            # Log-rilataj taskoj
│   │
│   ├── presenters/         # Prezentantoj (UI logic)
│   │   └── calendar/        # Kalendara prezentado
│   │
│   ├── factories/           # Domen-faktorioj
│   ├── mailers/             # Retmesaĝoj
│   ├── channels/            # WebSocket kanloj
│   ├── assets/              # Asistaj dosieroj
│   │   ├── stylesheets/     # Sass/CSS
│   │   ├── javascript/      # JavaScript
│   │   └── images/         # Bildoj
│   │
│   └── views/               # ERB-ŝablonoj
│       ├── admin/           # Admin vidpaĝoj
│       ├── api/             # API vidpaĝoj (JSON)
│       ├── devise/          # Devise vidpaĝoj
│       ├── event/           # Event-vidpaĝoj
│       └── layouts/         # Layout-ŝablonoj
│
├── config/                 # Rails konfigurado
│   ├── initializers/       # Iniciĝantoj
│   ├── locales/            # Tradukoj (eo, en, pt_BR)
│   ├── routes.rb           # Vojoj
│   └── database.yml        # Datumbaza konfigurado
│
├── db/                     # Datumbazo
│   ├── migrate/            # Migracioj (150+ dosieroj)
│   ├── seeds.rb            # Komencaj datumoj
│   └── structure.sql       # Datumbaza strukturo
│
├── test/                   # Testoj (Minitest)
│   ├── controllers/        # Kontrolistaj testoj
│   ├── models/             # Modelaj testoj
│   ├── services/           # Servaj testoj
│   ├── queries/            # Kveriaj testoj
│   ├── integration/        # Integraciaj testoj
│   ├── system/             # Sistemaj testoj
│   └── fixtures/           # Test-datumoj
│
├── openapi/                # API dokumentado
│   └── v2.yaml             # OpenAPI v2 specifiko
│
├── Dockerfile              # Docker konstruado
├── docker-compose.yml      # Docker Compose
├── Gemfile                 # Ruby dependecoj
├── package.json            # Node.js dependecoj
└── README.md
```

## Teknologia Stako

### Backend
- **Ruby**: 3.4.9
- **Rails**: 8.1.0
- **Database**: PostgreSQL 15.7
- **Cache**: Rails cache (default)
- **Job Queue**: Solid Queue 1.4.0
- **Job Monitoring**: Mission Control Jobs
- **Search**: PostgreSQL full-text + pg_search
- **Background Jobs**: Solid Queue (replaced Delayed Job)

### Authentication
- **Devise**: 5.0 (user authentication)
- **OmniAuth**: Facebook, Google OAuth2
- **JWT**: For API authentication
- **Simple Token Auth**: For mobile API clients

### Frontend
- **Framework**: Hotwire (Turbo + Stimulus)
- **CSS**: Bootstrap 5.3 + Sass
- **JS Bundler**: ESBuild 0.25.12
- **CSS Bundler**: Sass (cssbundling-rails)
- **Icons**: FontAwesome 6
- **Flags**: flag-icons 7.5.0
- **Maps**: Leaflet 1.9.4 + marker clustering

### API
- **v1**: Legacy REST API
- **v2**: Modern REST API with OpenAPI documentation
- **Formats**: JSON (primary), XML (for RSS feeds)

### Analytics & Monitoring
- **Ahoy**: User tracking & analytics (v5)
- **Sentry**: Error tracking (v6)
- **New Relic**: Performance monitoring
- **PaperTrail**: Version history tracking (v17)

### External Services
- **Geocoding**: Geocoder gem + Google Maps API
- **Timezones**: timezone gem + Google Timezone API
- **Email**: Postmark (primary), Sendmail (fallback)
- **Storage**: ActiveStorage (local or S3)
- **Payments**: None currently (future: Stripe?)

### Testing
- **Framework**: Minitest
- **Factories**: Custom factory pattern (app/factories/)
- **Fixtures**: Rails fixtures (preferred)
- **FactoryBot**: Available but use fixtures when possible
- **System Tests**: Capybara + Selenium
- **Mocking**: WebMock + VCR
- **Coverage**: SimpleCov

## Ĉefaj Modeloj kaj Rilatoj

### Event (Evento)
```
Event
├── belongs_to :user (creator)
├── belongs_to :country
├── has_many :participants
├── has_many :organizations, through: :organization_events
├── has_many :tags, through: :taggings
├── has_many :reports
├── has_many :videos
├── has_rich_text :enhavo (content)
├── has_many_attached :uploads
└── has_paper_trail

Fields:
- title, description, city, address
- date_start, date_end, time_zone
- online (boolean), format (onsite/hybrid/online)
- code (unique identifier), short_url
- latitude, longitude (geocoding)
- country_id, user_id
- participants_count, deleted (soft delete)
- international_calendar (boolean)
- metadata (jsonb)
```

### User (Uzanto)
```
User
├── has_many :events
├── has_many :organizations, through: :organization_users
├── has_many :participants
├── has_one_attached :picture
├── has_paper_trail
└── devise modules: database_authenticatable, registerable, recoverable, rememberable, validatable, confirmable, lockable, trackable, omniauthable

Fields:
- email, username, name, password
- admin (boolean), disabled (boolean), system_account (boolean)
- country_id
- authentication_token (for API)
- webcal_token, jwt_token
- confirmed_at, last_sign_in_at
- mailings (jsonb), instruo (jsonb), prelego (jsonb), ligiloj (jsonb)
```

### Organization (Organizo)
```
Organization
├── has_many :organization_users
├── has_many :users, through: :organization_users
├── has_many :organization_events
├── has_many :events, through: :organization_events
├── has_one_attached :logo
└── has_rich_text :description

Fields:
- name, short_name (unique), email, phone
- address, city, country_id
- url, youtube
- major (boolean), official (boolean), partner (boolean)
- display_flag (boolean)
```

### Country (Lando)
```
Country
├── has_many :users
├── has_many :events
└── has_many :cities (through events)

Fields:
- name, code (ISO 3166-1 alpha-2), continent
- id (special: 99999 = Reta/Online)
```

### Tag (Etikedo)
```
Tag
├── has_many :taggings
└── has_many :events, through: :taggings (polymorphic)

Fields:
- name, group_name (category/characteristic/time)
```

### Participant (Partoprenanto)
```
Participant
├── belongs_to :event
└── belongs_to :user

Fields:
- event_id, user_id
- public (boolean)
```

## Kontrolistoj

### Main Controllers
- **ApplicationController**: Base controller with Pagy, Internationalization, Sentry, PaperTrail
- **HomeController**: Home page, search, RSS feed, robots.txt
- **EventsController**: CRUD for events, filtering, sorting
- **UsersController**: User profiles, management
- **OrganizationsController**: Organization management

### API Controllers
- **Api::V1::EventsController**: Legacy API v1 for events
- **Api::V1::UsersController**: Legacy API v1 for users
- **Api::V2::EventsController**: Modern API v2 for events
- **Api::V2::OrganizationsController**: Modern API v2 for organizations

### Admin Controllers
- **Admin::DashboardController**: Admin dashboard
- **Admin::EventsController**: Event management
- **Admin::OrganizationsController**: Organization management
- **Admin::UsersController**: User management
- **Admin::ReportsController**: Report management
- **Admin::RedirectionsController**: URL redirection management
- **Admin::MockupsController**: UI mockups
- **Admin::StatisticsController**: Statistics dashboard

### Special Controllers
- **Webcal::WebcalController**: Calendar feed generation (iCalendar)
- **ComboboxController**: Autocomplete suggestions
- **InternationalCalendarController**: International calendar view
- **VideoController**: Video management
- **FollowersController**: User following functionality
- **ParticipantsController**: Event participation

## Servoj (Services)

### Service Pattern
```ruby
# app/services/resource/action_service.rb
module Resource
  class ActionService < ApplicationService
    attr_reader :param1, :param2

    # @param param1 [Type] Description
    # @param param2 [Type] Description
    def initialize(param1:, param2:)
      @param1 = param1
      @param2 = param2
    end

    # @return [ApplicationService::Response]
    def call
      # Business logic
      if success?
        success(result)
      else
        failure(error_message)
      end
    end

    private

    def success?
      # Check success condition
    end
  end
end
```

### Key Services
- **Events::CreateService**: Create new event
- **Events::UpdateService**: Update existing event
- **Events::SoftDeleteService**: Soft delete event
- **Users::DisableService**: Disable user account
- **Users::RegenerateApiToken**: Generate new API token
- **UserServices::MergeAccounts**: Merge two user accounts
- **Backup::DatabaseBackup**: Database backup
- **Housekeeping::Cleanup**: System cleanup tasks
- **TimeZone::Lookup**: Timezone lookup by coordinates
- **TimeZone::Normalize**: Normalize timezone identifiers

## Kverioj (Queries)

### Query Pattern
```ruby
# app/queries/resource/query_name.rb
module Resource
  class QueryName
    attr_reader :filter, :sort

    # @param filter [String, nil]
    # @param sort [Symbol, nil]
    def initialize(filter: nil, sort: nil)
      @filter = filter
      @sort = sort
    end

    # @return [ActiveRecord::Relation]
    def call
      scope = ResourceModel.all
      scope = scope.where(...) if filter.present?
      scope = scope.order(...) if sort.present?
      scope
    end
  end
end
```

### Key Queries
- **Events::UpcomingQuery**: Get upcoming events
- **Events::ByCountryQuery**: Filter events by country
- **Events::SearchQuery**: Search events by text
- **Users::TeachersAndSpeakersQuery**: Find teachers and speakers
- **Organizations::MembershipQuery**: Find organization members
- **Logs::FilterQuery**: Filter logs

## Taskoj (Jobs)

### Solid Queue
- Background job processing
- Admin interface at `/jobs`
- Commands:
  - `rails solid_queue:start` - Start worker
  - `docker compose up -d solid_queue` - Start in Docker

### Key Jobs
- **BackupDbJob**: Database backup
- **NewEventReportNotificationJob**: Notify about new event reports
- **SciigasUzantojnAntauEventoJob**: Notify users before events
- **GenerateStatisticsJob**: Generate statistics
- **HousekeepingJob**: System cleanup
- **WorkerHeartbeatJob**: Worker health monitoring
- **SitemapRefreshJob**: Refresh sitemap

## Vidoj (Views)

### Structure
```
app/views/
├── layouts/              # Layout templates
│   ├── application.html.erb  # Main layout
│   └── admin.html.erb        # Admin layout
│
├── shared/               # Shared partials
│   ├── _header.html.erb
│   ├── _footer.html.erb
│   └── _navbar.html.erb
│
├── home/                 # Home page views
│   ├── index.html.erb
│   └── search/
│
├── events/               # Event views
│   ├── index.html.erb
│   ├── show.html.erb
│   ├── form/
│   │   ├── _form.html.erb
│   │   └── ...
│   └── ...
│
├── admin/                # Admin views
│   ├── dashboard/
│   ├── events/
│   ├── organizations/
│   └── users/
│
├── api/                  # API views (JSON)
│   └── v2/
│       ├── events/
│       └── organizations/
│
└── devise/               # Authentication views
```

### Key Partials
- `_form.html.erb`: Event creation/editing form
- `_event_card.html.erb`: Event card display
- `_breadcrumb.html.erb`: Admin breadcrumb navigation
- `_map.html.erb`: Interactive map display

## Routing

### Main Routes
```ruby
# config/routes.rb

# Home
root to: "home#index"
get "/serchilo", to: "home#search"
get "/rss.xml", to: "home#feed"
get "/events.json", to: "home#events"

# Events
scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
  get "/:continent", to: "events#by_continent"
  get "/:continent/:country_name", to: "events#by_country"
  get "/:continent/:country_name/:city_name", to: "events#by_city"
end

# API
namespace :api do
  namespace :v2 do
    resources :events, only: [:index, :show]
    resources :organizations, only: [:index, :show]
  end
end

# Admin
authenticated :user, ->(user) { user.admin? } do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  mount MaintenanceTasks::Engine, at: "/maintenance_tasks"
end
namespace :admin do
  root to: "dashboard#index"
  resources :events
  resources :organizations
  resources :users
  # ...
end

# Webcal
namespace :webcal do
  get "lando/:landa_kodo", to: "webcal#lando"
  get "o/:short_name", to: "webcal#organizo"
  get "uzanto/:webcal_token", to: "webcal#user"
end

# Devise
devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations",
  omniauth_callbacks: "users/omniauth_callbacks",
  passwords: "users/passwords"
}
```

## Assets Pipeline

### JavaScript
- **Framework**: Stimulus + Turbo (Hotwire)
- **Bundler**: ESBuild (`esbuild.config.js`)
- **Entry point**: `app/javascript/application.js`
- **Controllers**: `app/javascript/controllers/`

### CSS
- **Framework**: Bootstrap 5.3
- **Preprocessor**: Sass (`cssbundling-rails`)
- **Entry point**: `app/assets/stylesheets/application.sass`
- **Main file**: `app/assets/builds/application.css`

### Key Assets
- **Icons**: FontAwesome 6 (`@fortawesome/fontawesome-free`)
- **Flags**: flag-icons (`node_modules/flag-icons`)
- **Maps**: Leaflet + MarkerCluster
- **Charts**: Chartkick + Highcharts

## API Documentation

### OpenAPI v2
- **File**: `openapi/v2.yaml`
- **Paths**:
  - `/api/v2/events` - List and create events
  - `/api/v2/events/{code}` - Get, update, delete event
  - `/api/v2/organizations` - List organizations
  - `/api/v2/organizations/{id}` - Get organization

### Authentication
- **API Token**: In `User` model, `authentication_token` field
- **JWT**: For v2 API (optional)

## Feedoj (RSS & Webcal)

### RSS Feeds
- **Format**: XML
- **Templates**: `app/views/events/*.xml.builder`
- **Examples**:
  - `/europo/Montenegro.xml` - Events in Montenegro
  - `/ameriko/Brazilo.xml` - Events in Brazil
  - `/reta.xml` - Online events
  - `/ik.xml` - International calendar events

### Webcal (iCalendar)
- **Format**: .ics
- **Module**: `app/modules/webcal.rb`
- **Routes**:
  - `/webcal/lando/:landa_kodo` - Events by country
  - `/webcal/o/:short_name` - Events by organization
  - `/webcal/uzanto/:webcal_token` - User's subscribed events

## Internationalization (I18n)

### Supported Locales
- **eo** (Esperanto) - Primary
- **en** (English) - Secondary
- **pt_BR** (Portuguese) - Tertiary

### Translation Files
```
config/locales/
├── eo.yml          # Esperanto
├── en.yml          # English
└── pt_BR.yml       # Portuguese
```

### UI Text
- **ALL UI text must be in Esperanto** (primary language)
- Translations should be added for all languages
- Use I18n helpers: `t(".key")`, `I18n.t(".key")`

## Security

### Authentication
- **Devise**: User authentication
- **OmniAuth**: Social login (Facebook, Google)
- **JWT**: API token authentication
- **Simple Token Auth**: Mobile API authentication

### Authorization
- **Admin**: `user.admin?`
- **Organization Admin**: `user.administranto?(organization)`
- **Event Owner**: `user.owner_of?(event)`
- **Organization Member**: `user.administranto?(organization)` or `user.in?(organization.uzantoj)`

### Protection
- **CSRF**: `protect_from_forgery with: :exception`
- **Sentry**: Error tracking with `Sentry.capture_exception(e)`
- **Rack Attack**: DDoS protection
- **CORS**: `rack-cors` for API
- **Bullet**: N+1 query detection (development)

---

**Lasta ĝisdatigo**: 2026-07-24
