class ClustersController < ApplicationController
  def index
    @names = ['Metropolis', 'Westeros', 'Tatooine']
    base = [[
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['-', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x']
          ],
          [
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x']
          ],
          [
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', '.', '.', 'o', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'o', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x'],
            ['x', 'x', 'x', 'x', 'x', 'x', 'x', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', 'x', 'x', 'x', 'x', 'x', 'x', 'x']
          ]]

    @data = base.map do |cluster_value|
      rows_length = cluster_value.map { |r| r.inject(0) { |n, s| n + (s == 'x' ? 1 : 0) } }

      { slots: rows_length.reduce(&:+), percent: 0, charts: [] }
    end

    @columns = base.map do |cluster_value|
      # Récupère le numbre de poste pour chaque rangée
      rows_length = cluster_value.map { |r| r.inject(0) { |n, s| n + (s == 'x' || s == '-' ? 1 : 0) } }
      # Clone la rangée avec le plus de poste
      columns = cluster_value[rows_length.index(rows_length.max)].clone
      # Renvoi une liste de colonnes
      columns.map!.with_index do |v, i|
        pred = i.pred == -1 ? [0, ''] : columns[i.pred]

        [pred[0] + (v == 'x' || v == '-' ? 1 : 0), v]
      end.map! { |k, v| v == 'x' || v == '-' ? k.to_s : '' }
    end

    users = UserInfoShort.all.map { |info| [info.user_id, info] }.to_h
    users.default = UserInfoShort.new

    @maps = base.map.with_index do |cluster_value, cluster_index|
      @data[cluster_index][:charts] = UserHistory.cluster(cluster_index + 1).users_by_hour
      histories = UserHistory.logged.cluster(cluster_index + 1).map { |history| [history.host, users[history.user_id]] }.to_h
      @data[cluster_index][:percent] = histories.length.to_f / @data[cluster_index][:slots] * 100
      @data[cluster_index][:slots] -= histories.length

      cluster_value.map.with_index do |row_value, row_index|
        row_length = row_value.length - 1
        columns = row_value.clone

        columns.map!.with_index do |v, i|
          pred = i.pred == -1 ? [0, ''] : columns[i.pred]

          [pred[0] + (v == 'x' || v == '-' ? 1 : 0), v]
        end.map! { |k, v| k }

        [row_index + 1, row_value.map.with_index do |station_value, station_index|
          case station_value
          when 'x', '-' then
            kind = :station
            class_name = %w(station)
            pred_station = row_value[station_index.pred]
            next_station = row_value[station_index.next]
            host = %Q(e#{cluster_index + 1}r#{row_index + 1}p#{columns[station_index]})
            user = histories[host]

            if station_index.zero? || (pred_station != 'x' && pred_station != '-')
              class_name << 'block-begin'
            elsif station_index == row_length || (next_station != 'x' && next_station != '-')
              class_name << 'block-end'
            elsif (pred_station == 'x' || pred_station == '-') && (next_station == 'x' || next_station == '-')
              class_name << 'block-middle'
            end

            if user
              class_name << 'station-success'

              unless user.new_record?
                data = user.serializable_hash(only: [:login])
                data.merge!({ title: user.display_name, placement: 'auto',
                              avatar: 'https://cdn.intra.42.fr/userprofil/' + user.login + '.jpg' })
              end
            else
              class_name << 'station-default'
            end
          when 'o' then
            kind = :obstacle
            class_name = %w(block-begin block-end station station-obstacle)
          else
            kind = :space
            class_name = %w(space)
          end

          { kind: kind, class: class_name || [], host: host, data: data || {} }
        end]
      end.to_h.sort { |a, b| b[0] <=> a[0] }
    end
  end

  def get
    render json: UserHistory.logged.cluster(params[:index]), status: :ok
  end
end
