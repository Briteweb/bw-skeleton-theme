<?php

	namespace BWSkeletonTheme;

	class Setup
	{

		/**
		 * Set up actions and filters
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @param arguments
		 * @return null
		 */

		public function __construct()
		{

			// Register theme support for thumbnails, menus, and remove theme support for backhrounds, headers and feed links
			add_action( 'after_setup_theme', array($this, 'after_setup_theme__addThemeSupport') );

		}



		/**
		 * Add theme support
		 *
		 * @author #BRITEWEB <@briteweb>
		 * @package bw-skeleton-theme
		 * @since 1.0
		 * @return null
		 */

		public function after_setup_theme__addThemeSupport()
		{

			// add theme support

		}/* after_setup_theme__addThemeSupport() */



	}/* class Setup */
