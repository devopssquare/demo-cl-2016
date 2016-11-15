include jenkins

jenkins::job {"helloworld-deploy-seed":
  # The require produces a dependency loop for some reason, make sure, Jenkins is up and running when this manifest is applied
  #  require => Class['jenkins'],
  config  => '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<project>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.disk__usage.DiskUsageProperty plugin="disk-usage@0.28"/>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.4.4">
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
    <javaposse.jobdsl.plugin.ExecuteDslScripts plugin="job-dsl@1.47">
      <targets>**/helloworldDeploy.groovy</targets>
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
exec {'build helloworld-deploy-seed':
  command => "java -jar /usr/share/jenkins/jenkins-cli.jar -i /var/lib/jenkins/.ssh/id_rsa -s http://localhost:8080/ build -s helloworld-deploy-seed",
  require => Jenkins::Job['helloworld-deploy-seed'],
  path    =>"/usr/bin",
}

# Then build helloworld
exec {'build helloworld':
  command => "java -jar /usr/share/jenkins/jenkins-cli.jar -i /var/lib/jenkins/.ssh/id_rsa -s http://localhost:8080/ build -s helloworld-deploy",
  require => Exec['build helloworld-deploy-seed'],
  path    =>"/usr/bin",
}
