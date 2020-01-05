## [1.4.0](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.4.0)
January 5 2020

#### Added
- _bodyFilter_ support for `put` and `patch` HTTP methods.
  - Added by [parfeon](https://github.com/parfeon) in Pull Request [#10](https://github.com/parfeon/YAHTTPVCR/pull/10).

## [1.3.0](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.3.0)
August 20 2018

#### Updated
- Cassette's scene playback logic based on callback from NSURL loading system.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#8](https://github.com/parfeon/YAHTTPVCR/pull/8).

#### Fixed
- Fixed `YHVTestCase` helper cassette's path generation.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#8](https://github.com/parfeon/YAHTTPVCR/pull/8).
- Fixed issue with requests from another cassettes playback during cassettes switch.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#8](https://github.com/parfeon/YAHTTPVCR/pull/8).
- Fixed code responsible for request's mock search.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#8](https://github.com/parfeon/YAHTTPVCR/pull/8).
- Fixed stalled mock data playback (when previous responses not received by consumer).
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#8](https://github.com/parfeon/YAHTTPVCR/pull/8).

## [1.2.3](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.2.3)
August 1 2018

#### Fixed
- Fixed `NSDictionary` category for query string generation.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#7](https://github.com/parfeon/YAHTTPVCR/pull/7).

## [1.2.2](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.2.2)
August 1 2018

#### Fixed
- Fixed empty response body playback.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#6](https://github.com/parfeon/YAHTTPVCR/pull/6).

## [1.2.1](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.2.1)
August 1 2018

#### Fixed
- Fixed set response VCR handler.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#5](https://github.com/parfeon/YAHTTPVCR/pull/5).

## [1.2.0](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.2.0)
July 31 2018

#### Updated
- `postBodyFilter` now accept body parameter which will pass body from request or it's stub.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#4](https://github.com/parfeon/YAHTTPVCR/pull/4).

## [1.1.3](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.1.3)
July 31 2018

#### Updated
- `taskIdentifier` replaced with `NSUUID`.
  - Updated by [parfeon](https://github.com/parfeon) in Pull Request [#3](https://github.com/parfeon/YAHTTPVCR/pull/3).

## [1.1.2](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.1.2)
July 31 2018

#### Fixed
- `postBodyFilter` should be used only for POST requests.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#2](https://github.com/parfeon/YAHTTPVCR/pull/2).

## [1.1.1](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.1.1)
July 30 2018

#### Added
- `isNewCassette` property.
  - Added by [parfeon](https://github.com/parfeon) in Pull Request [#1](https://github.com/parfeon/YAHTTPVCR/pull/1).

#### Fixed
- `allPlayed` calculation error.
  - Fixed by [parfeon](https://github.com/parfeon) in Pull Request [#1](https://github.com/parfeon/YAHTTPVCR/pull/1).

## [1.1.0](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.1.0)
July 30 2018

#### Added
- `NSURLConnection` support.
  - Added by [parfeon](https://github.com/parfeon).

## [1.0.0](https://github.com/parfeon/YAHTTPVCR/releases/tag/v1.0.0)
July 29 2018

#### Added
- Initial release of `YAHTTPVCR`.
  - Added by [parfeon](https://github.com/parfeon).