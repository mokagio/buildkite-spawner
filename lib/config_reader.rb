require 'psych'

def read_local_config(path = 'spawner.yml')
  return {} if File.exists?(path) == false

  Psych.safe_load(File.read(path), symbolize_names: true)
end

def add_commit_option(parser)
  parser.on('-c', '--commit SHA', String, 'The full SHA commit to spawn')
end

def add_pipeline_option(parser)
  parser.on('-p', '--pipeline PIPELINE', String, 'The name of the pipeline on which to spawn builds')
end

def add_number_option(parser)
  parser.on('-n', '--number NUMBER', Integer, 'How many builds have been run')
end

def add_organization_option(parser)
  parser.on('-o', '--organization ORG', String, 'How many builds to run')
end
