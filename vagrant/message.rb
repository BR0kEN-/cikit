def cikit_message(ip, host, is_wsl)
  blue = "\033[1;34m"
  green = "\033[1;32m"
  yellow = "\033[1;33m"
  # The green is a default color for this message output.
  reset = "\033[0m#{green}"

  message = <<-END
    |#{green}Releases changelog: #{yellow}https://cikit.slack.com/messages/general#{reset}
    |#{green}Technical support: #{yellow}https://cikit.slack.com/messages/support#{reset}
    |#{green}Documentation: #{yellow}https://github.com/BR0kEN-/cikit#{reset}
    |
    |#{blue} ██████╗ ██╗    ██╗  ██╗ ██╗ ████████╗#{reset}
    |#{blue}██╔════╝ ██║    ██║ ██╔╝ ██║ ╚══██╔══╝#{reset}
    |#{blue}██║      ██║    █████╔╝  ██║    ██║#{reset}
    |#{blue}██║      ██║    ██╔═██╗  ██║    ██║#{reset}
    |#{blue}╚██████╗ ██║    ██║  ██╗ ██║    ██║#{reset}
    |#{blue} ╚═════╝ ╚═╝    ╚═╝  ╚═╝ ╚═╝    ╚═╝#{reset}
    |
    |#{green}IP address: #{yellow}#{ip}#{reset}
    |#{green}Hostname: #{yellow}#{host}#{reset}
  END

  if is_wsl
    message += <<-END
      |
      |#{blue}Don't forget to add IP and hostname association for your#{reset}
      |#{blue}project to the #{yellow}"%SYSTEMROOT%\\system32\\drivers\\etc\\hosts".#{reset}
      |
      |#{blue}Also, make sure you are aware of the other limitations#{reset}
      |#{blue}on WSL: #{yellow}http://cikit.tools/vagrant/wsl/#limitations#{reset}
    END
  end

  message.gsub(/^\s+\|/, '')
end
