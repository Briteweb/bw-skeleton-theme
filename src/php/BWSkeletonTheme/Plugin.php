<?php

	namespace BWSkeletonTheme;

	class Plugin extends \BW\Plugin\StandardPlugin
	{

		/**
		 * @var (string) path of plugin main file (index.php)
		 */
		static public $path;

		/**
		 * @var (string) Plugin basename
		 */
		static public $basename;

		/**
		 * @var (string) Plugin version
		 */
		static public $version = '1.0.0';

		/**
		 * @var (array) Plugin version information
		 */
		static public $versionInfo;

		/**
		 * @var (string) URL for updates
		 */
		static public $updateUri = "http://plugins.briteweb.com";

		/**
		 * @var (string) Plugin homepage
		 */
		static public $url = "http://briteweb.com";

		/**
		 * @var (string) plugin slug (repository name)
		 */
		static public $slug;

		/**
		 * @var (string) Plugin language text domain
		 */
		static public $l10n;

		/**
		 * @var (string) Required PHP version
		 */
		static public $phpVersion = '5.3';

		/**
		 * @var (string) Required MySQL version
		 */
		static public $mysqlVersion = '5.0';


		/**
		 * Private constructor
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @return null
		 */

		private function __construct() {}


		/**
		 * Plugin initialization function.
		 *
		 * - init plugin variables
		 * - register plugin
		 * - define database options and tables
		 * - registers admin pages
		 * - instantiates plugin objects(s)
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @param arguments
		 * @return null
		 */

		static public function init( $path )
		{

			//initialize common plugin variables
			parent::init( $path );

			// instantiate plugin objects
			// That's where all the actions and filters go
			new Setup();


		}/* init() */



		/**
		 * Wordpress activation function
		 * upgrade database options and tables
		 *
		 * the callback functions could be different for each option.
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @param arguments
		 * @return null
		 */

		static public function activate()
		{


		}/* activate() */


		/**
		 * Wordpress deactivation function
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @param arguments
		 * @return null
		 */

		static public function deactivate()
		{

		}



	}/* class Plugin */
