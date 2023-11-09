.sidebar__container::before {
  content: '${env_name}';
  display: block;
  background-color: ${env_background_color};
  color: ${env_foreground_color};
  text-align: center;
  font-weight: bold;
  padding: 10px 4px;
  overflow: hidden;
  white-space: nowrap;
  margin-top: 20px;
}
.sidebar--collapsed .sidebar__container::before {
  content: '${env_abbreviation}';
  font-size: 140%;
  padding: 4px;
}
