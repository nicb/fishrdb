#
# $Id: driver_test.rb 599 2011-01-05 01:04:07Z nicb $
#
require 'test/test_helper'
require 'bundle_generator'

class DriverTest < ActiveSupport::TestCase

  FIXTURE_DATA_PATH = File.join(File.dirname(__FILE__), 'fixtures')
  TMPDIR_PATH = File.join(File.dirname(__FILE__), '..', '..', '..', 'tmp')

  def test_good_tar_config
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_tar_bundle.yml')
    do_test(good_config)
  end

  def test_good_zip_config
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_zip_bundle.yml')
    do_test(good_config, 'unzip -l')
  end

  def test_bad_no_system_config
    assert bad_config = File.join(FIXTURE_DATA_PATH, 'bad_no_system_bundle.yml')
    assert_raise(BundleGenerator::SystemConfigurationMissing) { BundleGenerator::Driver.non_interactive(bad_config, false) }
  end

  def test_bad_no_output_filename_config
    assert bad_config = File.join(FIXTURE_DATA_PATH, 'bad_no_output_filename_bundle.yml')
    assert_raise(BundleGenerator::OutputFilenameMissing) { BundleGenerator::Driver.non_interactive(bad_config, false) }
  end

  def test_good_with_defaults_config
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_tar_with_defaults_bundle.yml')
    do_test(good_config)
  end

  def test_good_with_no_files_config
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_tar_bundle_with_no_files.yml')
    do_test(good_config)
  end

  def test_tainting_config
    assert bad_config = File.join(FIXTURE_DATA_PATH, 'bad_but_not_fatal_bundle.yml')
    do_tainting_test(bad_config)
  end

  def test_good_with_empty_fields
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_tar_bundle_with_empty_fields.yml')
    do_test(good_config)
  end

  def test_good_with_array_errors
    assert good_config = File.join(FIXTURE_DATA_PATH, 'good_with_array_errors.yml')
    do_test(good_config)
  end

  def test_bad_with_non_existing_segments
    assert bad_config = File.join(FIXTURE_DATA_PATH, 'bad_with_non_existing_segments.yml')
    do_tainting_test(bad_config)
  end

private

  def do_test(conf, command_line = 'tar tvf')
    assert config = BundleGenerator::FileParser.new(conf)
    assert bundle = BundleGenerator::Bundle.new(config.data)
    assert output_path = BundleGenerator::Driver.non_interactive(conf, false)
    assert output_file = File.join(TMPDIR_PATH, File.basename(output_path))
    assert md5_file = output_file + '.md5'
    assert File.exists?(output_file)
    assert File.exists?(md5_file)
    assert tarred_files = IO.popen("#{command_line} #{output_file}") { |fh| fh.readlines }
    check_file_presence_into_bundle(bundle, tarred_files)
    assert File.unlink(output_file)
    assert File.unlink(md5_file)
  end

  def do_tainting_test(conf)
    assert output_path = BundleGenerator::Driver.non_interactive(conf, false)
    assert output_path =~ /-INCOMPLETE$/
    assert output_file = File.join(TMPDIR_PATH, File.basename(output_path))
    assert md5_file = output_file + '.md5'
    assert File.exists?(output_file)
    assert File.exists?(md5_file)
    assert File.unlink(output_file)
    assert File.unlink(md5_file)
  end

  def check_file_presence_into_bundle(bundle, archive)
    bundle.tapes.each do
      |t|
      t.tape_files.each { |tf| assert !archive.grep(/#{File.basename(tf.path)}/).blank?, "#{t.name}" } unless t.tape_files.blank?
      t.image_files.each { |tf| assert !archive.grep(/#{File.basename(tf.path)}/).blank?, "#{t.name}" } unless t.image_files.blank?
      t.meta_files.each { |tf| assert !archive.grep(/#{File.basename(tf.path)}/).blank?, "#{t.name}" } unless t.meta_files.blank?
    end
  end

end
