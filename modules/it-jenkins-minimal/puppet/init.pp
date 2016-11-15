include jenkins

jenkins::job {"helloworld-seed":
  # The require produces a dependency loop for some reason, make sure, Jenkins is up and running when this manifest is applied
  #  require => Class['jenkins'],
  config  => '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<project>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.disk__usage.DiskUsageProperty/>
  </properties>
  <scm class="hudson.plugins.git.GitSCM">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/devopssquare/helloworld-seed.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <javaposse.jobdsl.plugin.ExecuteDslScripts>
      <targets>**/helloworldInstall.groovy</targets>
      <usingScriptText>false</usingScriptText>
      <ignoreExisting>false</ignoreExisting>
      <removedJobAction>IGNORE</removedJobAction>
      <removedViewAction>IGNORE</removedViewAction>
      <lookupStrategy>JENKINS_ROOT</lookupStrategy>
      <additionalClasspath></additionalClasspath>
    </javaposse.jobdsl.plugin.ExecuteDslScripts>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>'
}

# For some reason jenkins::cli::exec does not set -i /var/lib/jenkins/.ssh/id_rsa
#jenkins::cli::exec {'build -s helloworld-seed':
#  require => Jenkins::Job['build -s helloworld-seed'],
#}

# So we have to execute it manually
exec {'build helloworld-seed':
  command => "java -jar /usr/share/jenkins/jenkins-cli.jar -i /var/lib/jenkins/.ssh/id_rsa -s http://localhost:8080/ build -s helloworld-seed",
  require => Jenkins::Job['helloworld-seed'],
  path    =>"/usr/bin",
}

# Then build helloworld
exec {'build helloworld':
  command => "java -jar /usr/share/jenkins/jenkins-cli.jar -i /var/lib/jenkins/.ssh/id_rsa -s http://localhost:8080/ build -s helloworld-install",
  require => Exec['build helloworld-seed'],
  path    =>"/usr/bin",
}
