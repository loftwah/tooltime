# config/tech_stack.rb

module TechStackConfig
  def self.load_tech_stack
    {
      'languages' => {
        'python' => { 
          source: 'endoflife',
          github: 'python/cpython',
          package_manager: 'pip'
        },
        'ruby' => { 
          source: 'endoflife',
          github: 'ruby/ruby',
          package_manager: 'rubygems'
        },
        'nodejs' => { 
          source: 'endoflife',
          github: 'nodejs/node',
          package_manager: 'npm'
        },
        'go' => { 
          source: 'endoflife',
          github: 'golang/go',
          package_manager: 'go'
        },
        'typescript' => {
          github: 'microsoft/TypeScript',
          package_manager: 'npm',
          npm_package: 'typescript'
        },
        'bun' => {
          github: 'oven-sh/bun',
          release_pattern: 'github'
        },
        'uv' => {
          github: 'astral-sh/uv',
          release_pattern: 'github'
        }
      },
      'databases' => {
        'postgresql' => { 
          source: 'endoflife',
          github: 'postgres/postgres'
        },
        'redis' => { 
          source: 'endoflife',
          github: 'redis/redis'
        },
        'sqlite' => {
          github: 'sqlite/sqlite',
          release_pattern: 'github'
        }
      },
      'frameworks' => {
        'rails' => { 
          source: 'endoflife',
          github: 'rails/rails',
          package_manager: 'rubygems'
        },
        'fastapi' => {
          github: 'tiangolo/fastapi',
          package_manager: 'pip',
          pypi_package: 'fastapi'
        }
      },
      'frontend' => {
        'tailwind' => {
          github: 'tailwindlabs/tailwindcss',
          npm_package: 'tailwindcss'
        },
        'vite' => {
          github: 'vitejs/vite',
          npm_package: 'vite'
        },
        'astro' => {
          github: 'withastro/astro',
          npm_package: 'astro'
        }
      },
      'testing' => {
        'rspec' => {
          github: 'rspec/rspec',
          package_manager: 'rubygems'
        },
        'playwright' => {
          github: 'microsoft/playwright',
          npm_package: '@playwright/test'
        }
      },
      'web_servers' => {
        'nginx' => { 
          source: 'endoflife',
          github: 'nginx/nginx'
        }
      },
      'devops' => {
        'terraform' => {
          github: 'hashicorp/terraform',
          release_pattern: 'github'
        },
        'github_actions' => {
          github: 'actions/runner',
          release_pattern: 'github'
        },
        'kamal' => {
          github: 'basecamp/kamal',
          package_manager: 'rubygems'
        },
        'tailscale' => {
          github: 'tailscale/tailscale',
          release_pattern: 'github'
        }
      },
      'cloud_services' => {
        'aws' => {
          status_url: 'https://health.aws.amazon.com/health/status',
          release_notes: 'https://aws.amazon.com/new'
        },
        'digitalocean' => {
          status_url: 'https://status.digitalocean.com',
          release_notes: 'https://docs.digitalocean.com/release-notes'
        },
        'cloudflare' => {
          status_url: 'https://www.cloudflarestatus.com',
          release_notes: 'https://developers.cloudflare.com/release-notes'
        }
      },
      'security' => {
        '1password' => {
          github: '1password/op',
          release_pattern: 'github'
        }
      },
      'ai_tools' => {
        'openai' => {
          api_version_url: 'https://platform.openai.com/docs/api-reference',
          models: ['gpt-4', 'gpt-3.5-turbo']
        },
        'anthropic' => {
          api_version_url: 'https://docs.anthropic.com/claude/reference',
          models: ['claude-3-opus', 'claude-3-sonnet']
        },
        'ollama' => {
          github: 'ollama/ollama',
          release_pattern: 'github'
        }
      },
      'monitoring' => {
        'prometheus' => {
          github: 'prometheus/prometheus',
          release_pattern: 'github'
        },
        'k6' => {
          github: 'grafana/k6',
          release_pattern: 'github'
        },
        'vector' => {
          github: 'vectordotdev/vector',
          release_pattern: 'github'
        },
        'axiom' => {
          status_url: 'https://status.axiom.co',
          api_docs: 'https://api.axiom.co/docs'
        }
      },
      'operating_systems' => {
        'ubuntu' => { 
          source: 'endoflife',
          github: 'ubuntu/ubuntu'
        }
      }
    }
  end

  def self.support_policies
    {
      'python' => 'Python releases are supported for 5 years from initial release. Check python.org for specific version details.',
      'ruby' => 'Ruby follows a yearly release cycle with security maintenance for ~3.75 years.',
      'nodejs' => 'Node.js even-numbered versions are LTS. LTS versions receive active support for 12 months and maintenance for 18 months.',
      'postgresql' => 'PostgreSQL versions are supported for 5 years after release.',
      'ubuntu' => 'Ubuntu LTS releases are supported for 5 years, while regular releases are supported for 9 months.',
      'rails' => 'Rails follows a 2.5 year support cycle for security fixes and severe bug fixes.'
    }
  end
end