# Disvolvig-Gvidilo - Eventa Servo

## Rapida Komenco

### Per Docker (Recomendita)

```bash
# Klonu la repositorion
git clone https://github.com/eventaservo/eventaservo.git
cd eventaservo

# Kopiu ekzemplan env-dosieron
cp env.Sample .env

# Aldonu RAILS_MASTER_KEY al .env
# (Generu per: bundle exec rails secret)
echo "RAILS_MASTER_KEY=viaja_test_ŝlosilo" >> .env

# Startu servojn
docker compose up -d

# Eniru en backend container
# (Se permesioj malsukcesas: sudo docker ... aŭ kolonu al docker grupo)
docker compose exec backend bash

# En la container:
bundle install
yarn install
rails db:create
rails db:migrate
rails db:seed

# Startu la servon (en aparta terminalo)
rails server -b 0.0.0.0 -p 3000

# Startu Solid Queue task-managero (en aparta terminalo)
docker compose up -d solid_queue

# Atingebla je: http://localhost:3000
```

### Sen Docker (Loke)

**Bezonoj**: Ruby 3.4.9, PostgreSQL 15+, Node.js 20+, Yarn

```bash
# Instalu dependecojn
bundle install
yarn install

# Kreu datumbazon
createdb eventaservo_devel
rails db:create
rails db:migrate
rails db:seed

# Startu servon
rails server

# En aparta terminalo: startu task-managero
bundle exec rails solid_queue:start
```

## Docker Compose Servoj

| Servo | Imaĝo | Portoj | Priskribo |
|-------|-------|-------|-------------|
| backend | eventaservo-dev | 3000 | Rails aplikaĵo |
| solid_queue | eventaservo-dev | - | Solid Queue laboristo |
| db | postgres:15.7 | 5432 | PostgreSQL datumbazo |
| selenium | selenium/standalone-chromium | 7900 | Test-broversilo (VNC) |

## Oftaj Taskoj

### Krei Novan Modelon
```bash
rails generate model ModelName field1:type field2:type
rails db:migrate
```

### Krei Novan Kontroliston
```bash
rails generate controller Namespace/ControllerName action1 action2
```

Adicionu al `config/routes.rb`:
```ruby
namespace :namespace do
  get 'path', to: 'controller#action'
end
```

### Krei Novan Servon
```ruby
# app/services/resource/action_service.rb
module Resource
  class ActionService < ApplicationService
    attr_reader :param1, :param2

    # @param param1 [Type] Priskribo
    # @param param2 [Type] Priskribo
    def initialize(param1:, param2:)
      @param1 = param1
      @param2 = param2
    end

    # @return [ApplicationService::Response]
    def call
      # Logiko ĉi tie
      if success_condition
        success(result)
      else
        failure("Error message")
      end
    end
  end
end
```

Uzu: `Resource::ActionService.call(param1: value1, param2: value2)`

### Krei Novan Kverion
```ruby
# app/queries/resource/query_name.rb
module Resource
  class QueryName
    # @param filter [String, nil]
    def initialize(filter: nil)
      @filter = filter
    end

    # @return [ActiveRecord::Relation]
    def call
      ResourceModel.order(:created_at)
    end
  end
end
```

### Krei Novan Taskon (Job)
```bash
rails generate job JobName
```

```ruby
# app/jobs/job_name_job.rb
class JobNameJob < ApplicationJob
  def perform(arg1, arg2)
    # Task-logiko ĉi tie
  end
end
```

### Krei Novan API Endpunkton
```ruby
# app/controllers/api/v2/resource_controller.rb
module Api
  module V2
    class ResourceController < Api::V2::ApiController
      def index
        @resources = Resource.all
        render json: @resources
      end

      def show
        @resource = Resource.find(params[:id])
        render json: @resource
      end
    end
  end
end
```

Adicionu al `config/routes.rb`:
```ruby
namespace :api do
  namespace :v2 do
    resources :resource, only: [:index, :show]
  end
end
```

### Aldoni Tradukojn
```yaml
# config/locales/eo.yml
eo:
  resource:
    index:
      title: "Rimedo"
    show:
      name: "Nomo"
```

## Solvado de Problemoj

### Datumbazo
- **Konektoproblemoj**: Kontrolu `docker ps` por vidi ĉu db container rulas
- **Kredo-problemoj**: Kontrolu `.env` (DB_HOST, DB_USERNAME, DB_PASSWORD)
- **Migracioj malsukcesas**: `rails db:migrate:redo`

### Dependecoj
- **Gemoj mankas**: `bundle install` en backend container
- **JS mankas**: `yarn install` en backend container
- **Bundler versio**: La projekto bezonas Bundler 4.0.5+

### Testoj
- **Malsukcesas**: Izoligu per `rails test test/path/to/specific_test.rb`
- **Kovrado**: `COVERAGE=true rails test`
- **Fixtures vs FactoryBot**: Preferu Fixtures (vidu TEST_ARCHITECTURE.md)

### Assets
- **CSS**: `yarn build:css`
- **JS**: `yarn build`
- **Ĉio**: `rails assets:precompile`

### Server
- **Port 3000 ne respondas**: Malkomentu `ports: - 3000:3000` en docker-compose.yml
- **Puma ne startas**: Kontrolu `RAILS_MASTER_KEY` en .env
- **Timezone eraro**: Bezonas `GOOGLE_TIMEZONE_API_KEY` en .env

### Docker
- **Permesioj**: Aldonu uzanton al docker grupo: `sudo usermod -aG docker $USER`
- **Container ne haltas**: `docker rm -f CONTAINER_NAME`
- **Logoj**: `docker compose logs -f`

## Mediumaj Variabloj

**Devige bezonataj** (aldonu al `.env`):
```bash
RAILS_MASTER_KEY=...          # Generu per: rails secret
```

**Opcialaj API-ŝlosiloj**:
```bash
GOOGLE_TIMEZONE_API_KEY=...   # Por timezone lookup
GOOGLE_GEOCODING_API_KEY=...  # Por geocoding
GOOGLE_CLIENT_ID=...         # Por Google OAuth
GOOGLE_CLIENT_SECRET=...     # Por Google OAuth
FACEBOOK_APP_ID=...           # Por Facebook OAuth
FACEBOOK_APP_SECRET=...       # Por Facebook OAuth
IPINFO_KEY=...                # Por IP-based geolocation
MAPBOX_ACCESS_TOKEN=...       # Por mapoj
POSTMARK_API_TOKEN=...        # Por retmesaĝoj
```

**Datumbazaj variabloj** (defaultoj jam funkcias por Docker):
```bash
DB_HOST=db
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=eventaservo_devel
```

## Utilaj Komandoj

```bash
# Datumbazo
rails db:create           # Krei datumbazon
rails db:migrate          # Ruli migraciojn
rails db:rollback         # Reverti lastan migracion
rails db:seed             # Plenigi per komencaj datumoj
rails db:reset            # Forviŝi kaj rekrei datumbazon

# Rails
rails console            # Interaktiva konsolo
rails routes              # Listo de ĉiuj vojoj
rails assets:precompile   # Kompili asistaĵojn

# Docker
docker compose up -d     # Starti ĉiuj servojn
docker compose down      # Halti ĉiuj servojn
docker compose build     # Rekonstrui imagen
docker compose logs -f   # Sekvi logojn
docker exec -it CONTAINER bash  # Eniri container

# Testoj
rails test               # Ĉiuj testoj
rails test:system        # Sistemaj testoj

# Kvalito
bundle exec standardrb    # Kontroli stilon
bundle exec standardrb --fix  # Aŭtomate korekti
bundle exec brakeman      # Sekureco-audito
bundle exec annotaterb    # Ĝisdatigi schema annotation

# Solid Queue
rails solid_queue:start   # Starti task-managero
# En Docker: docker compose up -d solid_queue
```

## Arkitekturaj Notoj

### Modeloj
- Sekvu Rails-konvenciojn
- Uzu `has_paper_trail` por historio
- Aldonu schema annotations (annotate gem)
- Validigoj: uzu Rails validigojn
- Scopes: por oftaj queries

### Kontrolistoj
- Heredu de `ApplicationController`
- Inkluzivas: Pagy, Internationalization, Sentry, PaperTrail
- Uzu `authenticate_user!` por aŭtentikado
- Uzu `authenticate_admin!` por admin-vojoj

### Servoj
- Heredu de `ApplicationService`
- Returu `success(result)` aŭ `failure(error)`
- Uzu `attr_reader` por parametroj

### Kverioj
- Pure read-only logiko
- Returu ActiveRecord::Relation
- Ne uzu en transaction-oj

### Testoj
- **DEVIGA**: Legu [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)
- Strukturo: `test/models/<model>/<konteksto>_test.rb`
- Namespaco: `ModelName::ContextTest`

## Admin Interfaco

- **URL**: `/admin` (nur por admin uzantoj)
- **Taskoj**: `/jobs` - Solid Queue monitorado
- **Maintenance**: `/maintenance_tasks` - Sistemaj taskoj
- **Breadcrumbs**: Ĉiu admin-paĝo DEVAS havi breadcrumb navigation

## API Dokumentado

- **v2 OpenAPI**: `openapi/v2.yaml`
- **Endpunktoj v2**:
  - `GET /api/v2/events` - Listo de eventoj
  - `GET /api/v2/events/{code}` - Unu evento
  - `GET /api/v2/organizations` - Listo de organizoj
  - `GET /api/v2/organizations/{id}` - Unu organizo

## Feedoj

### RSS
- **Format**: `.xml`
- **Ekzemploj**: `/europo/Montenegro.xml`, `/ameriko/Brazilo.xml`, `/reta.xml`
- **Ŝablonoj**: `app/views/events/*.xml.builder`

### Webcal (iCalendar)
- **Format**: `.ics`
- **Ekzemploj**:
  - `/webcal/lando/:country_code` - Eventoj por lando
  - `/webcal/o/:short_name` - Eventoj por organizo
  - `/webcal/uzanto/:webcal_token` - Eventoj por uzanto
- **Modulo**: `app/modules/webcal.rb`

---

**Lasta ĝisdatigo**: 2026-07-24
