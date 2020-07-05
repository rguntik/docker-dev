<?php

$handle = fopen("hostList.txt", "r");
$list = [];

while (($line = fgets($handle)) !== false) {
    $list[] = trim($line);
}

fclose($handle);
?>

<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>dev.loc list</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
          integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
</head>
<body>

<main role="main" class="container">
    <h1 class="mt-5">dev.loc list</h1>
    <ul class="list-group">
        <?php foreach ($list as $item) : ?>
            <li class="list-group-item"><a href="<?= $item ?>" target="_blank"><?= $item ?></a></li>
        <?php endforeach;?>
    </ul>
</main>

</body>
</html>

