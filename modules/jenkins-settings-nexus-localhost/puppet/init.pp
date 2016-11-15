file { '/var/lib/jenkins/.m2':
  ensure   => directory,
  owner    => 'jenkins',
  group    => 'jenkins',
  mode     => '0755',
}

file { '/var/lib/jenkins/.m2/settings.xml':
  owner    => 'jenkins',
  group    => 'jenkins',
  mode     => '0600',
  replace  => true,
  require  => File['/var/lib/jenkins/.m2'],
  content  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<settings xmlns=\"http://maven.apache.org/SETTINGS/1.0.0\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd\">

    <mirrors>
        <mirror>
            <id>localhost</id>
            <url>http://localhost:8081/nexus/content/groups/public</url>
            <mirrorOf>*</mirrorOf>
        </mirror>
    </mirrors>

    <profiles>
        <profile>
            <id>localhost</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <nexus.repository.host>localhost</nexus.repository.host>
                <nexus.repository.port>:8081</nexus.repository.port>
                <nexus.repository.base>/nexus</nexus.repository.base>
            </properties>
        </profile>
    </profiles>

    <servers>
        <server>
            <id>devopssquare-snapshots</id>
            <username>deployment</username>
            <password>deployment123</password>
        </server>
        <server>
            <id>devopssquare-releases</id>
            <username>deployment</username>
            <password>deployment123</password>
        </server>
        <server>
            <id>devopssquare-site</id>
            <username>deployment</username>
            <password>deployment123</password>
        </server>
    </servers>
</settings>",
}