# AGENTS.md - Gvidilo por AI-iloj

**Eventa Servo** estas Ruby on Rails-aplikaĵo por Esperanto-eventoj. UEA-projekto, AGPLv3+.

## Esencaĵoj

### Kodo
- **Lingvo**: Kodo/komentoj = Angla. UI-teksto = Esperanto
- **Stilo**: `bundle exec standardrb --fix` post ĉiu ŝanĝo. `frozen_string_literal: true` en ĉiuj .rb
- **Dokumentado**: YARD por ĉiuj klasoj/metodoj (inkl. privat)
- **Git**: Conventional Commits (Angla). Ne kreu branĉojn/komitojn/PR-ojn sen permeso

### Testoj
- **Deviga**: Legu [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) **antaŭ** skribi testojn
- Framework: Minitest. Preferu Fixtures super FactoryBot
- Strukturo: `test/models/<model>/<konteksto>_test.rb`

### Komandoj
```bash
# Disvolviĝo (Docker)
docker compose up -d                # Starti servojn
docker compose exec backend bash   # Eniri container
bundle install                       # Ruby dependecoj
yarn install                        # JS dependecoj
rails db:create db:migrate db:seed  # Datumbazo
rails server -b 0.0.0.0 -p 3000     # Starti servon

# Testoj
rails test                          # Ĉiuj testoj
rails test test/path/to/file        # Specifa testdosiero
COVERAGE=true rails test            # kun kovrado

# Kvalito
bundle exec standardrb --fix
bundle exec brakeman
```

### Teknologio
- Ruby 3.4.9, Rails 8.1.0, PostgreSQL 15.7
- Hotwire (Turbo+Stimulus), Bootstrap 5.3, ESBuild
- Solid Queue por taskoj, Devise+OmniAuth por aŭtentikado
- API v1 & v2 (OpenAPI: `openapi/v2.yaml`)

### Dosieroj
```
app/
  controllers/    # Kontrolistoj (API: api/v1/, api/v2/)
  models/         # Modeloj (Event, User, Organization, Country)
  services/       # Servoj (heredas ApplicationService)
  queries/        # Kverioj (pure read-only)
  jobs/           # Taskoj (Solid Queue)
  views/          # ERB-ŝablonoj (UI = Esperanto!)
  assets/        # CSS/JS (Bootstrap, Stimulus)
  presenters/    # Kompleksa UI-logiko
  factories/     # Domen-faktorioj (build/create)

test/            # Minitest (vidu TEST_ARCHITECTURE.md)
config/
  routes.rb      # Vojoj
  database.yml   # Datumbazo
db/
  migrate/       # Migracioj (150+)
  seeds.rb       # Komencaj datumoj
```

### Ŝlosiloj
- `eventaservo-test-builder` — Krei testojn laŭ projekta arkitekturo
- `eventaservo-yard-docs` — Generi YARD-dokumentadon
- `eventaservo-pr-creator` — Pretigi PR-ojn
- `eventaservo-code-review` — Revizii kodon

### Oftaj Taskoj
```ruby
# Nova modelo
rails g model ModelName field:type

# Nova kontrolisto
rails g controller Namespace/Controller action1 action2

# Nova servo
# app/services/resource/action_service.rb
module Resource
  class ActionService < ApplicationService
    attr_reader :param
    def initialize(param:); @param = param; end
    def call
      success(result) or failure(error)
    end
  end
end

# Nova kverio
# app/queries/resource/query_name.rb
module Resource
  class QueryName
    def call; ResourceModel.where(...); end
  end
end
```

### Mediumaj Variabloj (Docker)
```bash
RAILS_MASTER_KEY=...        # Deviga!
DB_HOST=db
DB_USERNAME=postgres
DB_PASSWORD=postgres
GOOGLE_TIMEZONE_API_KEY=...
GOOGLE_GEOCODING_API_KEY=...
IPINFO_KEY=...
```

### Solvado
- **Datumbazo ne konektiĝas**: Kontrolu `docker ps` (db container rulas?)
- **Gemoj mankas**: `bundle install` en backend container
- **Testoj malsukcesas**: `rails test test/path/to/file_test.rb` por izoli
- **Assets ne kompiliĝas**: `yarn build`
- **Port 3000 ne respondas**: Malkomentu `ports: - 3000:3000` en docker-compose.yml

---

**Pli da detalo**: [ARCHITECTURE.md](ARCHITECTURE.md) | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) | [README.md](README.md)
**Lasta ĝisdatigo**: 2026-07-24
