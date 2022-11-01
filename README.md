# Present

## Setup

### Prerequisites

The rest of the setup assumes you have the following installed in your local environment.

* Ruby 2.7.2. We recommend [RBenv](https://github.com/rbenv/rbenv) for managing your Ruby version.
* Rails 5.2.6
* Postgresql
* Bundler 2.2.11



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

To obtain the Google Cloud credentials, navigate to the Present Dashboard in the [Google Cloud Console](https://console.cloud.google.com/apis/dashboard?project=present-334418). Under "Credentials" select one of the OAuth 2.0 Client IDs. Currently the only one is named `Present-OAuth-Client`. Copy the Client ID and Client Secret and paste into the appropriate fields in `config/application.yml`.

Next you will need to obtain Zoom Credentials. Navigate to the [Zoom Marketplace](https://marketplace.zoom.us/) and select Manage > Present -> App Credentials. Copy the API Key and the API Secret into the appropriate fields in `config/application.yml`.

If you do not wish to use Figaro you will need to use another method to set the `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `ZOOM_API_SECRET`, and `ZOOM_API_KEY` environment variables.

It may be necessary to contact the maintainers in order to obtain access to the Google Cloud and Zoom Apps.

### Running Local

After installing prerequisites, installing dependencies, and setting environment variables, you should be able to run the app locally.


```
rails db:seed
rails s
```

Keep in mind that the app will make real HTTP calls to the Zoom API and Google Oauth.

## Contributing

* Please see the [project board](https://github.com/turingschool/present/projects/1) for open work.
* Select an unassigned issue from the `To Do` column and assign yourself or multiple people if you would like to pair.
* Move the card to `In Progress`
* If you need to pause working on an issue for more than a week, please unassign yourself and move back to `To Do`. If you have relevant work push up your branch and add notes to the issue
* Submit a Pull Request and fill out the PR template.
* Check that CircleCI tests pass
* Request a review
* Do not merge your own PR unless discussed and approved by the team


## Developer Resources:

* [project board](https://github.com/turingschool/present/projects/1)
* [Heroku Production](http://turing-present.herokuapp.com)
* [Heroku Staging](https://turing-present-staging.herokuapp.com/)
* [CircleCI](https://app.circleci.com/pipelines/github/turingschool/present?filter=all)
* [Wireframes](https://miro.com/app/board/o9J_luclx_c=/)
* [Saville Style System](https://savile.turing.edu/)
* [Google Cloud Console](https://console.cloud.google.com/apis/dashboard?project=present-334418)
* [Zoom Marketplace](https://marketplace.zoom.us/)
* [Original Planning Doc ](https://docs.google.com/document/d/1ugcAJbxE2dGzrFV5TtKsSu4ChoKkfs8bOQYno9aojXY/edit?usp=sharing)
* [DTR](https://docs.google.com/document/d/147gKRaigfph0sqzxPbEvch_m2d4EJpE_SV2RSU9aAts/edit?usp=sharing)
