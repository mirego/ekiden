# GitHub Actions Self-Hosted ARM64 MacOS Runner

The goal of this project is to have a pool of Mirego hosted runners in addition to the runners provided by GitHub. Those runners will be executed inside an ARM64 MacOS machine which should help speed up iOS builds.

## Configuration

- To configure a new host machine, follow the [host configuration guide](host/README.md)
- To create a new VM, follow the [guest configuration guide](guest/README.md)
- To setup the VM registry, follow the [registry configuration guide](registry/README.md)

---

## Architecture

### High Level Overview

Mirego will have a few machines hosted on premise. Those machines will be able to pick up jobs just like the GitHub hosted machines. The self-hosted runners will include tags in order to be explicitely chosen inside the workflows (`self-hosted`, `ARM64`, `mirego`...).

```mermaid
flowchart TD
    subgraph internet [Internet]
        subgraph spacer [ ]
            github(GitHub Actions)
        end
    end

    subgraph mirego [Mirego Network]
        subgraph spacer2 [ ]
            runner1(MacOS Runner 1):::machine<-->github
            runner2(MacOS Runner 2):::machine<-->github
            runner3(MacOS Runner 3):::machine<-->github
            runner4(MacOS Runner 4):::machine<-->github
        end
    end

    style mirego fill:transparent,stroke:#eb4b39,stroke-dasharray:5
    style internet fill:transparent,stroke:#4080ec,stroke-dasharray:5
    style github fill:#1d3a6e,stroke:#4080ec
    style spacer fill:transparent,stroke:transparent
    style spacer2 fill:transparent,stroke:transparent

    classDef machine fill:#15653a,stroke:#25ba6b
```

### Inside a Runner

In order to simplify maintenance and to increase the runner's reliability and the build's repeatability, each runner will run inside an ephemeral VM. This way, whenever a runner picks up a job, the workspace is assured to be in a clean state. This will also allow us to install and upgrade tools inside the VM and replicate it to every other machines.

A typical run-loop looks like this:

1. The _host_ machine generates a token from the GitHub API.
2. The _host_ machine launches a virtual machine (_guest_) with a cloned virtual disk.
3. The _host_ machine initiates an SSH connection to the _guest_ using a pre-defined hostname.
4. The _host_ machine launches the "runner" software pre-installed on the VM using the generated token.
5. The _guest_ machine waits for a job and executes it.
6. The _guest_ machine de-registers the runner from the GitHub organisation.
7. The _host_ machine shuts down the VM
8. The _host_ machine deletes the cloned virtual disk
9. Repeat

```mermaid
flowchart LR
    subgraph mirego [Mirego Network]
        subgraph spacer [ ]
            subgraph host [Mac OS Runner Host]
                subgraph spacer2 [ ]
                    script(Main Script)-->sshClient(SSH Client)
                    script--Launch-->guest
                    sshClient<-.->sshServer
                    subgraph guest [Mac OS VM]
                        sshServer(SSH Server)-->runner(Action Runner)
                        tools(Pre-Installed Tools)
                    end
                end
            end
        end
    end

    subgraph internet [Internet]
        runner<-->github(GitHub Actions)
    end


    style mirego fill:transparent,stroke:#eb4b39,stroke-dasharray:5
    style internet fill:transparent,stroke:#4080ec,stroke-dasharray:5
    style spacer fill:transparent,stroke:transparent
    style spacer2 fill:transparent,stroke:transparent

    style host fill:#15653a,stroke:#25ba6b
```
