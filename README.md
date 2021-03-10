
# AnarQ - An Open Source alternative to Facebook, Reddit, Disqus, etc

AnarQ is an Open Source social media platform that you can install on your local server,
providing you with feeds, posts, the ability to moderate posts, etc. Its most basic functionality
is that of serving as a forum HTTP backend web API.

## Configuring

In order to configure AnarQ you'll need to configure an SMTP server, since the systems frequently sends emails
to its registered users, to among other things have users verify their email address during registrations, etc.
To see how to configure this, visit the link below

* [magic.lambda.mail](https://github.com/polterguy/magic.lambda.mail)

In addition AnarQ requires its own configuration settings. You can find an example below.

```
  "anarq": {
    "frontend": {
      "url": "https://anarq.org"
    }
  },
```

Paste in the above into your configuration file, just above the `magic` parts, and modify it as needed.
Modify the actual frontend `url` according to where you have your frontend running.

## HTTP REST endpoints

AnarQ is a pure HTTP REST web API, allowing you to integrate it with any frontend client system you wish.
Below is te documentation for each endpoint in the system, grouped by section.

### Profile

This section contains everything related to authentication, registration, and public retrieval of profiles
for existing registered users in the system.

#### GET magic/modules/anarq/profile/authenticate

This endpoint allows you to authenticate a user with a username/password combination, provided as URL
encoded query parameters. Below is an example.

```
https://your-api-domain.com/magic/modules/anarq/profile/authenticate?username=foo4&password=bar
```

The above will return a JWT token back to the caller, without an expiration date, or more specifically an
expiration date 5 years into the future. This allows you to store the token in your client's persistent storage,
such as for instance `localStorage` in your browser, and use the token to authorize future requests towards
your backend.

This endpoint does not require the user to be authenticated.

#### POST magic/modules/anarq/profile/register

This endpoint registers a new user in the system. It takes the following payload.

```json
{
  "username": "username_on_site",
  "password": "password_on_site",
  "email": "john@doe.com",
  "full_name": "John Doe"
}
```

If the username or email address is already registered on the site, the endpoint will return failure,
explaining you exactly what went wrong.

The system will attempt to send an email to the registered email address, using configuration settings found
from your configuration file, allowing the user to confirm his email address. If you wish to edit this
template email, you can find it in _"/anarq/data/emails/confirm-email.txt"_. In order to send a valid email,
you need to configure your appSettings.json file having a value of anarq/frontend/url pointing to your
frontend's URL/confirm-email page, and you'll need to have a frontend URL being `/confirm-email`, accepting
the following query parameters.

* email
* secret

The secret needs to be supplied to the `confirm-email` endpoint later before the user can post, comment or
like posts/comments in the system.

This endpoint does not require the user to be authenticated.

#### GET magic/modules/anarq/profile/username-available

This endpoint returns true if the specified username is available. An example invocation can be found below.

```
https://your-api-domain.com/magic/modules/anarq/profile/username-available?username=foo3
```

If the username is registered from before, the above will result in the following result.

```json
{
  "result": false,
  "message": "Username already registered"
}
```

If the username is available, the above `result` field will have a value of `true`.

This endpoint does not require the user to be authenticated.

#### GET magic/modules/anarq/profile/email-available

This endpoint works exactly as the above username-available endpoint, except it of course
expects an `email` query parameter, and checks to see if the specified email address is registered
from before. If the email address is already registered from before, it will return something resembling
the following.

```json
{
  "result": false,
  "message": "Email address already registered"
}
```

If the email address is available, the above `result` field will have a value of `true`.

This endpoint does not require the user to be authenticated.

#### POST magic/modules/anarq/profile/confirm-email

This endpoints confirms a previously registered email address in the system, allowing the
registered user to prove he owns the email address specified as he or she registered at the site.
An example payload can be found below.

```json
{
  "email": "john@doe.com",
  "secret": "SOME_SECRET_HASH_VALUE_HERE"
}
```

The `secret` above needs to be the secret generated automatically by the system as the user registered
on the site, and is the SHA256 value of the combination of the user's email address, and the JWT auth
secret in your appSettings.json configuration file.

This endpoint does not require the user to be authenticated.

#### GET magic/modules/anarq/profile/me

This endpoint returns information about the currently authenticated user, and can be used
to retrieve meta data about the currently logged in user, such as his username, email, full name, etc.

This endpoint requires the user to be authenticated.

### Posts

This section contains everything related to retrieving OP posts from the backend.

#### GET magic/modules/anarq/posts/feed

Returns the most popular items according to the specified query parameters supplied. Popular
here meaning items having the most likes. The endpoint takes 5 QUERY parameters, all of which are
optional, and can be ommitted. Below is a list of parameters the endpoint can handle.

* limit - Maximum number of posts to return. If specified this must be in between the range of 0-100.
* offset - Offset from where to start retrieving items. Combined with the above, this allows you to page items in your frontend as you see fit.
* topic - Name of topic to return items from within. See sub section topic for an explanation of this.
* user - User that posted the OP.
* minutes - Number of minutes to filter by. Notice, can be multiplied with e.g. 86,400 to filter according to days, weeks, etc.

This is the main _"feed"_ endpoint, returning the most popular posts, according to what posts had the most upvotes. It allows you
to filter posts only submitted by a specific user, or posts submitted within a specific topic. The `minutes` filter allows you
to only return posts that were posted during the last n minutes, resulting in that old posts _"drops off"_ the feed over time,
regardless of how many upvotes they have. Which allows you to create feeds with most popular posts over the last 24 hours, 72 hours, etc
as you see fit.

The endpoint will return something resembling the following.

```json
[
  {
    "id": 3,
    "topic": "news",
    "created": "2021-03-09T08:50:17.000Z",
    "user": "john",
    "visibility": "protected",
    "excerpt": "Covid19 proven to be an international media hoax",
    "likes": 54
  },
  {
    "id": 1,
    "topic": "general",
    "created": "2021-03-09T08:21:46.000Z",
    "user": "peter",
    "visibility": "public",
    "excerpt": "The vaccine for Covid19 has a higher fatality rate than the disease",
    "likes": 37
  },
  /* ... etc ... */
]
```

Notice, the endpoint does _not_ return the actual contents of the posts, only an excerpt including its first 50 characters. If you want to retrieve
the entire content of a post, you'll have to use the GET `posts/post` invocation instead.

#### GET magic/modules/anarq/posts/post

This endpoint returns a single post, including its entire content, and number of likes it currently has.
It takes one single QUERY parameter being the `id` of the post to return. Invoking it with the following
URL ...

```
https://your-api-domain.com/magic/modules/anarq/posts/post?id=3
```

... might return something resembling the following.

```json
{
  "id": 3,
  "topic": "news",
  "created": "2021-03-09T08:50:17.000Z",
  "user": "root",
  "visibility": "protected",
  "content": "This is ANOTHER news OP posting",
  "likes": 1
}
```

Notice, only authenticated users having confirmed their email address can retrieve posts that does not
have _"public"_ as their `visibility` setting. And posts that have been moderated will only be returned
to users belonging to one of the following roles.

* root
* admin
* moderator

All other users can only see posts that are either _"public"_ or "_protected"_. Protected implies
only visible for registered users at the site, having confirmed their email address.

#### POST magic/modules/anarq/posts/post

This endpoint creates a new OP post, and requires the user to be authenticated, and having confirmed his email address.
It takes the following payload.

```json
{
  "visibility": "public",
  "topic": "news",
  "content": "Actual content of your post. Can be Markdown"
}
```

The `visibility` parts above must be one of the pre-defined visibility settings that exists in the system,
typically one of the following values.

* public
* protected
* moderated

Public posts are visible to anyone, including users just passing by as visitors, not being authenticated. Protected posts
are only for users that have registered on the site, and having confirmed their email address. Moderated is typically
not really interesting when creating a post, but rather applied later by a moderator if he or she chooses to moderate the
posting for some reasons.

The endpoint will return the ID of the item created, allowing you to for instance instantly navigate to the item, or
somehow show it to the user as it's created.

### PUT magic/modules/anarq/posts/post

This endpoint updates an existing post, but can only be invoked by the user that originally created the post, and
exists such that users can edit their existing posts, after having saved them. An example payload can be found below.

```json
{
  "id": 67777,
  "content": "This is the new updated content of the post, and will overwrite existing content",
  "visibility": "public"
}
```

A user can change both the content of the post, and the visibility of the post using this endpoint.

#### DELETE magic/modules/anarq/posts/post

TODO: Implement with similar semantics as its PUT counterparts ...

#### GET magic/modules/anarq/posts/posts-count

This endpoint returns the number of OP posts in the system. If invoked by an authenticated user having confirmed
his or her email address, the endpoint will return count of both public and protected posts given the specified
filtering conditions. If invoked by a visitor not authenticated, it will only return count of public posts.
If invoked by a moderator, admin or root account, it will return count of _all_ posts, including moderated posts.

The endpoint takes the following optional filtering conditions.

* topic - Only show posts from within the specified topic
* user - Only show posts created by the specified user

#### GET magic/modules/anarq/posts/posts

This endpoint works similarly to the above `posts/feed` endpoint, except it will not sort by popularity, but
rather when the post was created. This allows you to retrieve all posts in the system, and page through them as
you see fit, sorted by when the posts were created.

Notice, the endpoint will only return public posts unless invoked by an authenticated user having confirmed
his or her email address. And if invoked by a moderator, admin or root account, the endpoint will return also
moderated posts.
