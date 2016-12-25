# Jenkins

After building of the remote server you'll have the Jenkins CI installed on `https://YOUR.DOMAIN/jenkins`. It's configured in a way that everyone, who have an access to that URL, - is an administrator. Protection achieved by setting basic HTTP authentication for the whole domain using [Nginx](#nginx).

Here's the view of Jenkins home screen:

![Home screen](images/home-screen.png)

## Remarks

### Nginx

Nginx - is a global web server. It serving all connections and proxies requests to Jenkins, Solr and Apache. All requests are secured by basic HTTP authentication you've configured during installation the CIKit.
