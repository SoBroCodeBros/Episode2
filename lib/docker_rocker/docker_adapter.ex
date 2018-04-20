defmodule DockerRocker.DockerAdapter do
  @path "/var/run/docker.sock" |> URI.encode_www_form
  @url "http+unix://#{@path}"
  def containers do
    case HTTPoison.get("#{@url}/containers/json") do
      {:ok, %HTTPoison.Response{body: body}} ->
         body |> Poison.decode!
      {:error, error} ->
        error
    end
  end

  def create_container do
    image_settings = Poison.encode!(%{
                                      "Image" => "ubuntu",
                                      "Tty"  => true,
                                      "AttachStdin"  => true,
                                      "OpenStdin"  => true,
                                      "AutoRemove"  => false,
                                      "Cmd"  => "bash",
                                    })
    headers = [{"Content-Type", "application/json"}]
    case HTTPoison.post("#{@url}/containers/create", image_settings, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
         %{"Id" => id} = body |> Poison.decode!
         start_container(id)
      {:error, error} ->
        error
    end
  end

  def start_container(uid) do
    case HTTPoison.post("#{@url}/containers/#{uid}/start", "") do
      {:ok, %HTTPoison.Response{}} ->
        uid
      {:error, error} ->
        error
    end
  end
end
