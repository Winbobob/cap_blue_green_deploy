module CapBlueGreenDeploy::Tasks::Cleanup
  def cleanup_task_run
    local_releases = capture("ls -xt #{releases_path}").split.reverse

    current_live = capture("readlink #{deploy_to}/current_live | awk -F '/' '{ print $NF }'").strip
    previous_live = capture("readlink #{deploy_to}/previous_live | awk -F '/' '{ print $NF }'").strip
    local_releases.select! { |release| release != current_live && release != previous_live  }

    if keep_releases >= local_releases.length
      logger.important "no old releases to clean up"
    else
      logger.info "keeping #{keep_releases} of #{local_releases.length} deployed releases"
      directories = (local_releases - local_releases.last(keep_releases)).map { |release|
        File.join(releases_path, release) }.join(" ")

      try_sudo "rm -rf #{directories}"
    end
  end
end