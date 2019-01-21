# Web-VLC

[![Build Status](https://travis-ci.com/ScreamingHawk/web-vlc.svg?branch=master)](https://travis-ci.com/ScreamingHawk/web-vlc)

A website for selecting shows to watch locally on VLC.

## Features

* Configure a list of video locations
* Recognise series and seasons
* Load poster art, plot and more from IMDB
* Volume and seek controls from your browser
* Modern UI and design

## Configuration

There are a couple of points of configuration required to use this app correctly.

### VLC configuration

VLC must be configured to expose it's web API.

To do this, check the following setting.

1. `Tools > Preferences`
2. At the bottom for `Show settings`, check `All`
3. `Interface > Main interfaces`
4. Check the `web` checkbox
5. `Interface > Main interfaces > Lua`
6. Enter a password into `Lua HTTP > Password`. (This password goes into the app configuration below)
7. `Save`
8. Close and re-open VLC
9. Accept the network prompt if shown
10. Navigate to `http://localhost:8080` to see if it worked

### App configuration

Copy `server/config.example.yaml` to `server/config.yaml`.

Edit `server/config.yaml` with your defaults.

Ensure the `vlc.command` works in your console.

Copy the paths to your videos into `files.locations`.

#### Folder Watching

The application watches for changes in the supplied folders by default. To disable this, change the value at `files.watch` to `false`.

#### Secure HTTPS

To ensure `HTTPS` set the value of `server.secure` in `server/config.yaml` to `true`.

Copy your private key to `server/cert/private.pem`.
Copy your certificate to `server/cert/public.pem`.

For more information on how to generate these keys for your site you can check out this [blog post about Let's Encrypt][1].

#### Enable downloading

To enable a download ⤓ button for each video, set the value of `client.downloadEnabled` in `server/config.yaml` to `true`.

#### Enable streaming

To enable a stream ≋ button for each video, set the value of `client.streamEnabled` in `server/config.yaml` to `true`.

#### API - OMDb

[OMDb][2] is an API for IMDb. Using this feature will add plot and rating information for each of your shows.

This feature is disabled by default.

To enable this feature, optain a key from the [OMDb website][2] and add it to the setting `api.omdb.key`, then set the `api.omdb.enabled` flag to `enabled`.

#### API - MAL

[MyAnimeList][3] is by far the best source of anime information. Using this feature will add plot and rating information for each of your shows.

This feature is disabled by default.

To enable this feature, set the `api.mal.enabled` flag to `enabled`.

Please note that MyAnimeList has a very relaxed search feature which may result in poor matches.

#### API - Preference

With both API enabled, there may be a preference to use one set of results over another. This can be configured with the `api.prefer` flag.

This feature is set to `omdb` by default.

#### API - Cache Period

Data returned from the APIs are cached for a number of days.

This number of days is configurable with the configuration parameter `api.cacheDays`.

This feature is set to `30` by default.

### Video file structure

Files must be organised like so:

```yml
Show Name
  - Season x
    - video_episode_xx.ext
```

Season folder may be omitted.
There is some intelligence to detect episode number, otherwise the video name can be anything.

## Usage

Install dependencies.

```sh
npm i
```

Edit `server/config.yaml` with your defaults.

Build everything and run in a single command, because you are lazy.

```sh
npm run complete
```

Navigate to the application at `http://localhost:3000`.
Note your path may be different if you changed the config.

## Development

Watch for CoffeeScript changes.

```sh
npm run coffee-watch
```

Watch for Webpack changes.

```sh
npm run webpack-watch
```

Run server watching for changes.

```sh
npm run start-watch
```

[1]: https://michael.standen.link/2018/06/22/lets-encrypt-cert.html
[2]: https://www.omdbapi.com/
[3]: https://myanimelist.net/

## Support on Beerpay
Hey dude! Help me out for a couple of :beers:!

[![Beerpay](https://beerpay.io/ScreamingHawk/web-vlc/badge.svg?style=beer-square)](https://beerpay.io/ScreamingHawk/web-vlc)  [![Beerpay](https://beerpay.io/ScreamingHawk/web-vlc/make-wish.svg?style=flat-square)](https://beerpay.io/ScreamingHawk/web-vlc?focus=wish)
