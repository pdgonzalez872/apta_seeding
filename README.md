This is a clone of the APTA seeding app I wrote earlier in 2018 but written in Elixir. This is not finished nor we will continue the project.

There are some interesting parts of this project that did get done:

- [The ETL process and API is done well I believe:] (https://github.com/pdgonzalez872/apta_seeding/tree/master/lib/apta_seeding/etl)

Here is the readme from the other project. Please let me know if you have any questions by reaching out to me via email.

# Update

After a successful run in the busiest part of the season, we are glad to retire the app. The APTA has agreed that this was an important feature and
are going to build it on their end as we mention below in the "Limitations" section.
It was a lot of fun while it lasted, but we are happy that the process will be flawless now.

# About this project

This project started to help calculate the Presidents Cup standings for Region 5 to save Ben McKnight some time.

It just so happened that in order to calculate the correct standings, we had to know which results to use in the calculation.

By fetching and organizing the results in a sane way, we got to the point where we could make correct calculations based on them.

That's what happens when seeding a tournament, so we looked into that.

One thing led to the other and we now have a way to solve a couple of problems:

- Real time calculation of PCup standings for Region 5
- Real time seeding of tournaments based on the current APTA seeding rules and current player list on the website
- Display a current result report for a player
- Display the points for an individual team for a hypothetical tournament

It is always a great feeling when we can leverage technology to solve a real problem. This app does just that.

If you have a similar problem or want to discuss how technology can help your business, please contact us at contact@kaseconsultingllc.com

# Tech Stack

- Rails 5 (started as an API only and went to full Rails)
- Postgresql
- Hosted on Heroku [https://apta-seeding.herokuapp.com/](https://apta-seeding-rebirth.herokuapp.com/)

# Seeding process

The current process relies on a very clever Excel spreadsheet that does some magic and is able to come up with results that are about 90% accurate.

This app does the same as the magic spreadsheet and also solves the 10% left. This saves the APTA seeding committee quite a bit of time.

# Limitations

We rely on scraping text from the APTA website to gather tournament results and from that we infer teams/players and the results that go with them.

We also rely on weekly tasks that we will run in the background to get new tournament results and update our database accordingly.

We incur all of the issues that come with scraping and not owning the data, but this app serves as a temporary seam to help the seeding process until the APTA can do it on their end.

The task is on their roadmap and they will get to it soon.

# Acknowledgements

Thanks Kels for letting me (Paulo) put in a decent amount of time into this project.

The work didn't impact our work at [Kase Consulting](https://www.linkedin.com/company/18271818/), but she did wonder why I was looking so much at paddle results.

Thanks Benny McKnight, Scott Kahler, Eric Miller, Ray Crosta, Graham McNerney and Randy Lofgren for providing test cases and consistently trying to break the app. :)

# Contributing

We accept pull requests from anyone. Please create an issue so we can discuss it prior to creating the pull request.

<div style="text-align:center"><img src="kc_logo.jpg" alt="Drawing" style="width: 200px;"/></div>
