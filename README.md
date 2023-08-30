# Present

Manage Turing student attendances.

[Deployed Here](https://present.turing.edu/)

## Local Setup

### Prerequisites

The rest of the setup assumes you have the following installed in your local environment.

* Ruby 3.1.4. We recommend [RBenv](https://github.com/rbenv/rbenv) for managing your Ruby version.
* Rails 7.0.4.3
* Postgresql
* Bundler 2.3.7



Other versions may work. If you wish to test other versions you will have to modify the `Gemfile`, remove `Gemfile.lock` and run `bundle install`.


To set up locally, clone this repo and run the following commands.

```
bundle install
rails db:create
rails db:migrate
bundle exec rspec
```

You should have all passing tests. If you do not, make sure you have met the prerequisites.

### Environment Variables

To run locally you will need to set up some environment variables. This project includes [Figaro](https://github.com/laserlemon/figaro) in its Bundler environment and can be used to set up environment variables:

```
bundle exec figaro install
```

Then, open the file `config/application.yml`. Copy and paste the following template into the file:

```
GOOGLE_OAUTH_CLIENT_ID: <YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE>
GOOGLE_OAUTH_CLIENT_SECRET: <YOUR_GOOGLE_OAUTH_CLIENT_SECRET_HERE>
ZOOM_API_SECRET: <YOUR_ZOOM_API_SECRET_HERE>
ZOOM_API_KEY: <YOUR_ZOOM_API_KEY_HERE>
```

**Note: It may be necessary to contact the maintainers in order to obtain access to the Google Cloud App. Alternatively, you can create your own Google Cloud project with OAuth credentials.**

To obtain the Google Cloud credentials, navigate to the Present Dashboard in the [Google Cloud Console](https://console.cloud.google.com/apis/dashboard?project=present-334418). Under "Credentials" select one of the OAuth 2.0 Client IDs. Currently the only one is named `Present-OAuth-Client`. Copy the Client ID and Client Secret and paste into the appropriate fields in `config/application.yml`.

Next you will need to obtain Zoom Credentials. Follow [these instructions](https://marketplace.zoom.us/docs/guides/build/server-to-server-oauth-app/#create-a-server-to-server-oauth-app) to create a Server to Server Oauth App with Zoom. You do not need to enable WebHooks. Select the appropriate scopes to get meeting details and meeting reports. Then, copy the API Key and the API Secret into the appropriate fields in `config/application.yml`.

If you do not wish to use Figaro you will need to use another method to set the `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `ZOOM_API_SECRET`, and `ZOOM_API_KEY` environment variables.

**PLEASE KEEP IN MIND THAT THESE ARE LIVE CREDENTIALS**

Avoid making execessive API calls to Zoom or Google or you could hit rate limits. If you write any new tests that trigger API calls, make sure that WebMock is intercepting these calls. WebMock should be enabled by default. **DO NOT DISABLE WEBMOCK IN YOUR TESTS**.

### Running Local

After installing prerequisites, installing dependencies, and setting environment variables, you should be able to run the app locally.

```
rails db:seed
rails s
```

##### Running Sidekiq locally

You need redis running for sidekiq.

```
brew install redis
bundle exec sidekiq
```

Keep in mind that the app will make real HTTP calls to the Zoom API and Google Oauth.

### Schema

![Schema](./doc/schema.jpg)

## Contributing

If you would like to contribute, please contact @BrianZanti on Github or Turing Slack.

## Developer Resources:

* [project board](https://www.notion.so/e2903cbd009d45329a9324d83cfb44ec?v=72ee4cad35ab44cab4b41c712e7b8dd0)
* [Staging](https://present-staging.turing.edu/)
* [CircleCI](https://app.circleci.com/pipelines/github/turingschool/present?filter=all)
* [Wireframes](https://miro.com/app/board/o9J_luclx_c=/)
* [Saville Style System](https://savile.turing.edu/)
* [Google Cloud Console](https://console.cloud.google.com/apis/dashboard?project=present-334418)
* [Zoom Marketplace](https://marketplace.zoom.us/)
