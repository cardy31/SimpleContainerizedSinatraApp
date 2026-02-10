# AGENTS.md

## Project Overview

A containerized Sinatra web application with an Nginx reverse proxy, designed for deployment on a Raspberry Pi cluster. The app returns the hostname of the container serving the request, demonstrating round-robin load balancing across multiple app instances.

## Architecture

**Production (Raspberry Pi cluster):**

```
Client
  |
  v
Proxy Pi (Nginx, port 80)
  |  round-robin
  +----------+----------+
  |                     |
  v                     v
App Pi 1              App Pi 2
(Sinatra, port 4567)  (Sinatra, port 4567)
```

- **Proxy Pi**: Runs Nginx on port 80, load-balances across the two app Pis.
- **App Pi 1 & 2**: Each runs a containerized Sinatra app on port 4567 via Puma.

**Local (docker-compose):**

The `docker-compose.yml` runs both the app and proxy on a single host. Nginx proxies to the `app` service by Docker DNS name. This is useful for development but does not replicate the multi-host Pi setup.

## Project Structure

```
.
├── AGENTS.md                  # This file — project context for AI agents
├── CLAUDE.md                  # Points to AGENTS.md
├── README.md                  # Project readme
├── docker-compose.yml         # Local dev: runs app + proxy on one host
├── app/
│   ├── Dockerfile             # Ruby 3.2.2 image, installs gems
│   ├── Gemfile                # Dependencies: sinatra, puma, rackup, rack-test, test-unit
│   ├── Gemfile.lock           # Locked dependency versions
│   ├── app.rb                 # Sinatra app — single GET / route returning hostname
│   ├── config.ru              # Rack config, boots Sinatra::Application
│   ├── run_tests.rb           # Test runner script
│   └── test/
│       └── test.rb            # Unit tests (Test::Unit + Rack::Test)
├── proxy/
│   ├── Dockerfile             # Nginx image with apache2-utils
│   └── nginx.conf             # Nginx config: upstream + reverse proxy
└── .github/
    └── workflows/
        └── ruby.yml           # CI: runs tests on push/PR to main
```

## Key Files

### `app/app.rb`
The Sinatra application. Defines a single `GET /` route that returns `"Hostname: <container hostname>"`. This makes it easy to verify which instance is serving a request behind the load balancer.

### `app/config.ru`
Rack configuration file. Loads `app.rb` and runs `Sinatra::Application`. Used by the `rackup` command in docker-compose.

### `proxy/nginx.conf`
Nginx configuration. Defines an upstream `sinatra-app` pointing to `app:4567` (Docker service name). In production on the Pi cluster, this must be updated with the actual IP addresses of the app Pis.

### `docker-compose.yml`
Local development setup. Runs two services:
- `app`: Builds from `./app`, runs `bundle exec rackup` on `0.0.0.0:4567`, mounts `./app` as a volume for live reloading.
- `proxy`: Uses the stock `nginx` image with `nginx.conf` mounted in, exposes port 80, depends on `app`.

### `app/Dockerfile`
Based on `ruby:3.2.2`. Copies Gemfile/Gemfile.lock and runs `bundle install`. The app code is mounted via volume in docker-compose rather than copied into the image.

### `proxy/Dockerfile`
Based on `nginx`. Installs `apache2-utils` (for benchmarking tools like `ab`), copies `nginx.conf` into the image, and exposes port 80.

## Running Tests

```sh
ruby app/run_tests.rb
```

This runs the Test::Unit suite in `app/test/`. Tests use `Rack::Test` to make requests against the Sinatra app and verify the response.

Prerequisites: install dependencies first with `cd app && bundle install`.

## CI/CD

GitHub Actions workflow (`.github/workflows/ruby.yml`):
- **Triggers**: push or pull request to `main`
- **Environment**: Ubuntu, Ruby 3.0
- **Steps**: installs gems via `BUNDLE_GEMFILE=app/Gemfile bundle install`, then runs `ruby app/run_tests.rb`

## Dependencies

| Dependency  | Purpose                                |
|-------------|----------------------------------------|
| Ruby 3.2.2  | Runtime (Docker image)                 |
| Sinatra     | Web framework                          |
| Puma        | Application server                     |
| Rackup      | Rack launcher                          |
| Rack::Test  | HTTP testing helper                    |
| Test::Unit  | Test framework                         |
| Nginx       | Reverse proxy / load balancer          |

## Deployment Notes

- The `docker-compose.yml` is for **local single-host development only**. It does not replicate the production Pi cluster topology.
- In production, each Pi runs its own container. The proxy Pi's `nginx.conf` must list the real IP addresses of the app Pis in the `upstream` block instead of the Docker service name `app`.
- Deployment instructions will be added here later.
