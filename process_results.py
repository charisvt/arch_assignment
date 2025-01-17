import os
import csv
import matplotlib.pyplot as plt

def parse_stats_file(stats_file):
    """
    Parse a stats.txt file and extract statistics.
    """
    stats = {}
    with open(stats_file, "r") as f:
        for line in f:
            # Skip empty lines or lines without at least two columns
            if not line.strip() or len(line.split()) < 2:
                continue
            
            # Split the line by whitespace and take the stat name and value
            parts = line.split()
            stat_name = parts[0]
            stat_value = parts[1]

            try:
                # Attempt to convert the value to an int
                stats[stat_name] = int(stat_value)
            except ValueError:
                print(f"Warning: Non-numeric value for {stat_name} in {stats_file}. Skipping.")

    return stats

def process_results():
    """
    Process the results from the stats.txt files in the fibonacci_sims directory
    and save the desired data to a CSV file.
    """
    result_dir = "fibonacci_sims"
    output_csv = os.path.join(result_dir, "simulation_results.csv")
    
    # Fields to extract from stats.txt
    required_stats = [
        "sim_ticks",
        "sim_insts",
        "system.l2.overall_hits::total",
        "system.l2.overall_misses::total",
    ]

    # Prepare to write to CSV
    with open(output_csv, mode="w", newline="") as csvfile:
        csvwriter = csv.writer(csvfile)
        # Write the header
        csvwriter.writerow(["CPU", "Clock", "Memory Config", *required_stats, "Miss Rate"])

        # Traverse through the directories inside fibonacci_sims
        for root, dirs, files in os.walk(result_dir):
            for dir_name in dirs:
                stats_file = os.path.join(root, dir_name, "stats.txt")
                if os.path.exists(stats_file):
                    # Parse the stats file
                    stats = parse_stats_file(stats_file)

                    # Unpack the folder name into its components
                    try:
                        cpu, clock, mem_config = dir_name.split("_", maxsplit=2)
                    except ValueError:
                        print(f"Skipping config {dir_name} due to unexpected format.")
                        continue  # Skip this iteration if unpacking fails

                    # Extract the required stats
                    row = [cpu, clock, mem_config]
                    miss_rate = None

                    for stat in required_stats:
                        if stat in stats:
                            row.append(stats[stat])
                        else:
                            row.append("N/A")

                    # Calculate miss rate if data is available
                    if "system.l2.overall_misses::total" in stats and "system.l2.overall_hits::total" in stats:
                        total_accesses = stats["system.l2.overall_hits::total"] + stats["system.l2.overall_misses::total"]
                        miss_rate = float(stats["system.l2.overall_misses::total"] / total_accesses) if total_accesses > 0 else None
                    row.append(miss_rate if miss_rate is not None else "N/A")

                    # Write the row to the CSV
                    csvwriter.writerow(row)
    
    print(f"Results saved to {output_csv}")

if __name__ == "__main__":
    process_results()