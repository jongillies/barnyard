barnyard is a data sync engine

## Motivation

Given legacy data sources, slow data sources or data sources with crappy API's
how can we detect changes in these systems an funnel data to downstream consumers wiht ease?

* How do we detect changes in a system?
* How can we data from source X to several cosumers?
* API for getting data from X is icky.
* Using the "sync engine", consumer are unaware of any complexity.

Barnyard is not a data wharehouse.  At any point in time it contains a snapshot
of a data source.  It does not provide any historical information other than
aggretate data change metrics.  For an application that stores ALL historical
information checkout [storehouse|https://github.com/jongillies/storehouse].

## Our Solution - barnyard

* Provide near real time updates to the consumers via queue subscriptions.
* Levefage one "harvester" of data for many consumers.
* Provide metrics on aggreate data changes.
* Provide change nofiication on select events.

## Terminology

* Crop - The data source
* Harvester - Get the data
* Barn - Store the data
* Farmer - Distribute the data
* Subscriber - Consumer of the data

## Components

### barnyard_harvester

The barnyar_harvester is the data sync engine.  It abstracts the complexity of
syncronziation from the harvesters.  To use the harvester all you have to do is
iterate your data source and send the data to the harvester object.
The rest is automatic.

### Cachecow

CacheCow is a Rails application that configures the metadata for the harvester.

The back-end is MySQL and more can be found here: XXX

### External Components

* Data store via Motena (Usually Redis)
* Queue via RabbitMQ or SQS

## Harvesters

The following harvesters are provided "out of the box":

* barnyard_aws - Harvesters for AWS Object
* IN_PROGRESS: barnyard_dns - Monitor DNS Chagnes
* TO_DO: barnyard_ad-dg - Monitor Active Directory distribution group (DG) changes

## How it works

* Setup data sources (crops) using CacheCow
* Setup subscribers using CacheCow
* Schedule/run your harvester for the data
* Schedule/run your consumer for the data

Some screeshots from CacheCow.  You will notice the nifty statistics:

![Subscriptions](https://raw.github.com/jongillies/cachecow/master/img/change.png)


