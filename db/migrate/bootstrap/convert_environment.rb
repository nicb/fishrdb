# 
# $Id: convert_environment.rb 82 2007-11-26 11:29:09Z nicb $
#
# This is used by conversion environments to figure out
# proper inclusions and paths
#

require 'yaml'

$top_prefix 		= File.expand_path(File.dirname(__FILE__) + '/../../..')
$config_prefix		= $top_prefix + '/config/'
$model_prefix		= $top_prefix + '/app/models/'
$fixtures_prefix 	= $top_prefix + '/test/fixtures/'
$config_prefix		= $top_prefix + '/config/'
$helper_prefix		= $top_prefix + '/app/helpers/'

require $config_prefix + 'environment'
#require 'active_record'
#require 'active_support'
#require	$model_prefix + 'auth'
#require $helper_prefix + 'save_conditioner'
require $helper_prefix + 'display/model/display_helper'
require $helper_prefix + 'form_helper'
require $helper_prefix + 'yaml_loader'
require	$model_prefix + 'description_level'
require	$model_prefix + 'container_type'
require	$model_prefix + 'user'
require	$model_prefix + 'document'
#require	$model_prefix + 'node'
#require	$model_prefix + 'series_document'
#require	$model_prefix + 'score_document'
