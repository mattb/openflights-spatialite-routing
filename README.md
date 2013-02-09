OpenFlights routing with Spatialite
===================================

This is some ruby code using SQLite 3 and Spatialite to create a routing database from OpenFlights air routes, allowing route queries. It assumes Spatialite is installed in /usr/local/lib as it would be if installed using homebrew on Mac.

```$ ruby load.rb
...

$ ruby try.rb SFO BQN
By least stops:

SFO San Francisco to BQN Aguadilla
----------------------------------
SFO San Francisco to JFK New York
JFK New York to BQN Aguadilla

By shortest distance travelled:

SFO San Francisco to BQN Aguadilla
----------------------------------
SFO San Francisco to FLL Fort Lauderdale
FLL Fort Lauderdale to BQN Aguadilla
```
