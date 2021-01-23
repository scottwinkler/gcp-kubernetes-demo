output "urls" {
  value = {
    repo = google_sourcerepo_repository.repo.url
    app  = "http://helloworld.default.${data.shell_script.domain_name.output["domain_name"]}/helloworld"
  }
}