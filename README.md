# MKDocs on Docker

A Dockerfile for deploying a [MKDocs](http://www.mkdocs.org/) which is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation.

This image is registered to the [Docker Hub](https://hub.docker.com/r/nutsllc/toybox-mkdocs/) that is the official docker image registory.

## What is the MKDocs

>MkDocs is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Documentation source files are written in Markdown, and configured with a single YAML configuration file.

>### Host anywhere
Builds completely static HTML sites that you can host on GitHub pages, Amazon S3, or anywhere else you choose.

>### Great themes available
There's a stack of good looking themes included by default. Choose from bootstrap, readthedocs, or any of the 12 bootswatch themes. You can also check out a list of 3rd party themes in the MkDocs wiki, or better yet, add your own.

>### Preview your site as you work
The built-in devserver allows you to preview your documentation as you're writing it. It will even auto-reload whenever you save any changes, so all you need to do to see your latest edits is refresh your browser.

>### Easy to customize
Get your project documentation looking just the way you want it by customizing the theme.

* [Learn more](http://redis.io/topics/introduction)

## Usage

To run MKdocs container:

```
docker run --name mkdocs -p 8000:8000 -itd nutsllc/toybox-mkdocs
```

Then open your web browser and access ``http://localhost:8000``

## License

* MKDocs - BSD License

## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/nutsllc/toybox-redis/issues), or submit a [pull request](https://github.com/nutsllc/toybox-redis/pulls) with your contribution.